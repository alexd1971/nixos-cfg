{ pkgs, ... }:

{
  # Enable the system Sway wrapper so sessions get the right portals and GTK env.
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # ReGreet gives a lightweight graphical login without pulling in a full desktop manager.
  services.displayManager.regreet = {
    enable = true;
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
        exec "${pkgs.regreet}/bin/regreet; swaymsg exit"
        input "type:touchpad" {
          tap enabled
          natural_scroll enabled
        }
        input "type:keyboard" {
          xkb_layout us,ru
          xkb_options grp:win_space_toggle
        }
      '';
    in
    "${pkgs.sway}/bin/sway --config ${greeterSwayConfig}";

  # Session tools used by the Home Manager Sway config.
  environment.systemPackages = with pkgs; [
    swayidle
    swaylock

    foot
    waybar
    wofi
  ];
}
