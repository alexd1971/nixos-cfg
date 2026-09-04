{ pkgs, ... }:

let
  keepAwake = pkgs.writeShellScriptBin "keep-awake" ''
    exec ${pkgs.systemd}/bin/systemd-inhibit \
      --what=sleep:shutdown:idle \
      --who=keep-awake \
      --why="Long-running user command" \
      --mode=block \
      "$@"
  '';

  hasIdleInhibitor = pkgs.writeShellScript "has-idle-inhibitor" ''
    if ${pkgs.systemd}/bin/systemd-inhibit --list --no-legend | ${pkgs.gnugrep}/bin/grep -qE '(^|:)idle(:|$)'; then
      exit 0
    fi

    exit 1
  '';

  hasSleepOrIdleInhibitor = pkgs.writeShellScript "has-sleep-or-idle-inhibitor" ''
    if ${pkgs.systemd}/bin/systemd-inhibit --list --no-legend | ${pkgs.gnugrep}/bin/grep -qE 'sleep|idle'; then
      exit 0
    fi

    exit 1
  '';

  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl --class=backlight";

  smoothDimIfUninhibited = pkgs.writeShellScript "smooth-dim-if-uninhibited" ''
    if ${hasIdleInhibitor}; then
      exit 0
    fi

    state_dir="''${XDG_RUNTIME_DIR:-/tmp}/sway-power"
    brightness_state="$state_dir/brightness"
    token_state="$state_dir/token"
    lock_file="$state_dir/brightness.lock"

    ${pkgs.coreutils}/bin/mkdir -p "$state_dir"
    token="$(${pkgs.coreutils}/bin/date +%s%N)-$$"

    (
      ${pkgs.util-linux}/bin/flock 9
      printf '%s\n' "$token" > "$token_state"
    ) 9>"$lock_file"

    if current=$(${brightnessctl} get 2>/dev/null) \
      && max=$(${brightnessctl} max 2>/dev/null) \
      && [ "$max" -gt 0 ]; then
      :
    else
      exit 0
    fi

    target=$((max * 12 / 100))
    [ "$target" -lt 1 ] && target=1

    if [ "$current" -le "$target" ]; then
      exit 0
    fi

    (
      ${pkgs.util-linux}/bin/flock 9
      if [ "$(${pkgs.coreutils}/bin/cat "$token_state" 2>/dev/null || true)" = "$token" ] && [ ! -r "$brightness_state" ]; then
        printf '%s\n' "$current" > "$brightness_state"
      fi
    ) 9>"$lock_file"

    steps=50
    step=1
    while [ "$step" -le "$steps" ]; do
      if [ "$(${pkgs.coreutils}/bin/cat "$token_state" 2>/dev/null || true)" != "$token" ]; then
        exit 0
      fi

      value=$((current - ((current - target) * step / steps)))
      [ "$value" -lt "$target" ] && value="$target"

      (
        ${pkgs.util-linux}/bin/flock 9
        if [ "$(${pkgs.coreutils}/bin/cat "$token_state" 2>/dev/null || true)" = "$token" ]; then
          ${brightnessctl} set "$value" >/dev/null 2>&1 || true
        fi
      ) 9>"$lock_file"

      step=$((step + 1))
      ${pkgs.coreutils}/bin/sleep 0.1
    done
  '';

  screenOffIfUninhibited = pkgs.writeShellScript "screen-off-if-uninhibited" ''
    if ${hasIdleInhibitor}; then
      exit 0
    fi

    exec ${pkgs.sway}/bin/swaymsg 'output * power off'
  '';

  screenOnAndRestore = pkgs.writeShellScript "screen-on-and-restore" ''
    state_dir="''${XDG_RUNTIME_DIR:-/tmp}/sway-power"
    brightness_state="$state_dir/brightness"
    token_state="$state_dir/token"
    lock_file="$state_dir/brightness.lock"

    ${pkgs.coreutils}/bin/mkdir -p "$state_dir"
    token="$(${pkgs.coreutils}/bin/date +%s%N)-$$"

    (
      ${pkgs.util-linux}/bin/flock 9
      printf '%s\n' "$token" > "$token_state"
    ) 9>"$lock_file"

    if [ ! -r "$brightness_state" ]; then
      ${pkgs.sway}/bin/swaymsg 'output * power on' >/dev/null 2>&1 || true
      exit 0
    fi

    read -r target < "$brightness_state"
    case "$target" in
      ""|*[!0-9]*)
        ${pkgs.coreutils}/bin/rm -f "$brightness_state"
        exit 0
        ;;
    esac

    if max=$(${brightnessctl} max 2>/dev/null) \
      && [ "$max" -gt 0 ]; then
      :
    else
      ${pkgs.sway}/bin/swaymsg 'output * power on' >/dev/null 2>&1 || true
      exit 0
    fi

    [ "$target" -gt "$max" ] && target="$max"

    (
      ${pkgs.util-linux}/bin/flock 9
      if [ "$(${pkgs.coreutils}/bin/cat "$token_state" 2>/dev/null || true)" = "$token" ]; then
        ${brightnessctl} set "$target" >/dev/null 2>&1 || true
        ${pkgs.coreutils}/bin/rm -f "$brightness_state"
      fi
    ) 9>"$lock_file"

    ${pkgs.sway}/bin/swaymsg 'output * power on' >/dev/null 2>&1 || true
  '';

  suspendIfIdle = pkgs.writeShellScript "suspend-if-idle" ''
    if ${hasSleepOrIdleInhibitor}; then
      exit 0
    fi

    if ${pkgs.procps}/bin/pgrep -af 'sshd: .*(pts|notty)' >/dev/null; then
      exit 0
    fi

    if ${pkgs.procps}/bin/pgrep -af 'nix (build|copy|develop|run|shell|store)|nixos-rebuild|nix-build|nix-store|curl|wget|rsync|scp|sftp|cargo|rustc|ghc|cabal|stack|make|ninja|gcc|g\+\+|clang|cc1|ld(\.| |$)' >/dev/null; then
      exit 0
    fi

    network_bytes() {
      total=0
      for iface in /sys/class/net/*; do
        name=''${iface##*/}
        [ "$name" = lo ] && continue
        [ -r "$iface/statistics/rx_bytes" ] || continue
        [ -r "$iface/statistics/tx_bytes" ] || continue

        read -r rx < "$iface/statistics/rx_bytes"
        read -r tx < "$iface/statistics/tx_bytes"
        total=$((total + rx + tx))
      done
      echo "$total"
    }

    before=$(network_bytes)
    ${pkgs.coreutils}/bin/sleep 10
    after=$(network_bytes)

    # Treat roughly 25 KiB/s as active transfer and skip this idle suspend.
    if [ $((after - before)) -ge 262144 ]; then
      exit 0
    fi

    exec ${pkgs.systemd}/bin/systemctl suspend
  '';
in

{
  wayland.windowManager.sway = {
    # Hide the Wayland pointer after a short idle period, including on swaylock.
    extraConfig = ''
      seat * hide_cursor 1000
    '';
  };

  # Shared Sway idle policy for every Home Manager user on desktop hosts.
  services.swayidle = {
    enable = true;
    systemdTargets = [ "sway-session.target" ];
    events = {
      before-sleep = "${pkgs.swaylock}/bin/swaylock -f";
      lock = "${pkgs.swaylock}/bin/swaylock -f";
    };
    timeouts = [
      {
        timeout = 240;
        command = "${smoothDimIfUninhibited}";
        resumeCommand = "${screenOnAndRestore}";
      }
      {
        timeout = 300;
        command = "${pkgs.swaylock}/bin/swaylock -f";
      }
      {
        timeout = 600;
        command = "${screenOffIfUninhibited}";
        resumeCommand = "${screenOnAndRestore}";
      }
      {
        timeout = 900;
        command = "${suspendIfIdle}";
      }
    ];
  };

  home.packages = [
    keepAwake
  ];

  programs.swaylock = {
    enable = true;
    settings = {
      color = "111111";
      indicator-idle-visible = false;
      show-failed-attempts = true;
    };
  };
}
