{ pkgs, ... }:

{
  # Lightweight Wayland notification daemon for the Sway session.
  services.mako = {
    enable = true;
    settings = {
      anchor = "top-right";
      layer = "overlay";

      width = 360;
      height = 120;
      margin = 12;
      padding = 12;
      border-size = 2;
      border-radius = 10;

      font = "DejaVu Sans 11";
      background-color = "#2e3440";
      text-color = "#eceff4";
      border-color = "#5e81ac";
      progress-color = "over #88c0d0";

      icons = true;
      max-icon-size = 48;
      markup = true;
      actions = true;

      default-timeout = 6000;
      max-visible = 5;
      sort = "-time";

      "urgency=low" = {
        border-color = "#4c566a";
        default-timeout = 4000;
      };

      "urgency=high" = {
        border-color = "#bf616a";
        default-timeout = 0;
      };
    };
  };

  wayland.windowManager.sway.config.keybindings = {
    "Mod4+n" = "exec ${pkgs.mako}/bin/makoctl dismiss";
    "Mod4+Shift+n" = "exec ${pkgs.mako}/bin/makoctl dismiss --all";
  };

  systemd.user.services.mako = {
    Unit = {
      Description = "Lightweight Wayland notification daemon";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.mako}/bin/mako";
      Restart = "on-failure";
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };

  home.packages = [
    # Provides notify-send for manual notification checks and scripts.
    pkgs.libnotify
  ];
}
