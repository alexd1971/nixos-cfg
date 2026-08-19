{ pkgs, lib, ... }:

{
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  services.displayManager.regreet = {
    enable = true;
    settings = {
      GTK = {
        application_prefer_dark_theme = true;
      };
    };
  };

  services.greetd.settings.default_session.command =
    let
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
}