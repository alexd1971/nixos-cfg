{ pkgs, ... }:

{
  # Show Blueman in the Waybar tray and keep Bluetooth controls reachable in Sway.
  systemd.user.services.blueman-applet = {
    Unit = {
      Description = "Blueman Bluetooth tray applet";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.blueman}/bin/blueman-applet";
      Restart = "on-failure";
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}
