{ pkgs, ... }:

{
  # Enable the system Sway wrapper so sessions get the right portals and GTK env.
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # Apply the same idle/lock policy to every Home Manager user on desktop hosts.
  home-manager.sharedModules = [
    ../../../home/common/desktop-theme.nix
    ../../../home/common/sway-power.nix
  ];

  # Home Manager installs swaylock, but PAM auth must be enabled system-wide.
  security.pam.services.swaylock = { };

  # ReGreet gives a lightweight graphical login without pulling in a full desktop manager.
  services.displayManager.regreet = {
    enable = true;
    theme = {
      package = pkgs.gnome-themes-extra;
      name = "Adwaita-dark";
    };
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
    font = {
      package = pkgs.dejavu_fonts;
      name = "DejaVu Sans";
      size = 12;
    };
    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
    };
    extraCss = ''
      #reboot_button,
      #poweroff_button,
      #reboot_button:hover,
      #poweroff_button:hover,
      #reboot_button:checked,
      #poweroff_button:checked,
      button.destructive-action,
      button.destructive-action:hover,
      button.destructive-action:checked {
        background: #3f3f46;
        color: #f4f4f5;
        border-color: #52525b;
        box-shadow: none;
        min-height: 32px;
        min-width: 32px;
        padding: 4px 8px;
        border-radius: 8px;
        font-size: 12px;
      }

      #reboot_button,
      #poweroff_button {
        margin-bottom: 0;
      }

      #reboot_button {
        margin-right: 4px;
      }

      button.destructive-action:hover {
        background: #52525b;
      }
    '';
    settings = {
      GTK = {
        application_prefer_dark_theme = true;
      };
    };
  };

  # Allow the greeter user to expose power actions on the login screen.
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      var isLoginAction = [
        "org.freedesktop.login1.power-off",
        "org.freedesktop.login1.power-off-ignore-inhibit",
        "org.freedesktop.login1.power-off-multiple-sessions",
        "org.freedesktop.login1.reboot",
        "org.freedesktop.login1.reboot-ignore-inhibit",
        "org.freedesktop.login1.reboot-multiple-sessions",
        "org.freedesktop.login1.suspend",
        "org.freedesktop.login1.suspend-ignore-inhibit",
        "org.freedesktop.login1.suspend-multiple-sessions",
        "org.freedesktop.login1.hibernate",
        "org.freedesktop.login1.hibernate-ignore-inhibit",
        "org.freedesktop.login1.hibernate-multiple-sessions"
      ].indexOf(action.id) >= 0;

      if (isLoginAction && subject.user == "greeter") {
        return polkit.Result.YES;
      }
    });
  '';

  services.greetd.settings.default_session.command =
    let
      # Run ReGreet inside a tiny Sway session so the greeter works on Wayland.
      greeterSwayConfig = pkgs.writeText "greeter-sway.conf" ''
        font pango:DejaVu Sans 12
        seat * xcursor_theme Bibata-Modern-Ice 30
        exec "${pkgs.regreet}/bin/regreet >/dev/null 2>&1; printf '\033[2J\033[H'; ${pkgs.sway}/bin/swaymsg exit >/dev/null 2>&1"
        input "type:touchpad" {
          tap enabled
          natural_scroll enabled
        }
        input "type:keyboard" {
          xkb_layout us,ru
          xkb_options grp:win_space_toggle
        }
      '';
      greeterSway = pkgs.writeShellScript "greeter-sway" ''
        printf '\033[2J\033[H'
        exec ${pkgs.sway}/bin/sway --config ${greeterSwayConfig} >/dev/null 2>&1
      '';
    in
    "${greeterSway}";

  # Session tools used by the Home Manager Sway config.
  environment.systemPackages = with pkgs; [
    bibata-cursors
    swayidle
    swaylock

    gnome-themes-extra
    papirus-icon-theme

    foot
    waybar
    wofi
  ];
}
