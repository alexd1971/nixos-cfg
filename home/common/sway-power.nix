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

  screenOffIfUninhibited = pkgs.writeShellScript "screen-off-if-uninhibited" ''
    if ${hasIdleInhibitor}; then
      exit 0
    fi

    exec ${pkgs.sway}/bin/swaymsg 'output * power off'
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
    events = {
      before-sleep = "${pkgs.swaylock}/bin/swaylock -f";
      lock = "${pkgs.swaylock}/bin/swaylock -f";
    };
    timeouts = [
      {
        timeout = 300;
        command = "${pkgs.swaylock}/bin/swaylock -f";
      }
      {
        timeout = 600;
        command = "${screenOffIfUninhibited}";
        resumeCommand = "${pkgs.sway}/bin/swaymsg 'output * power on'";
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
