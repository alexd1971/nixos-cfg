{ pkgs, ... }:

{
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --cmd sway";
        user = "greeter";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    # Sway session tools
    swayidle
    swaylock

    # Terminal / launcher / bar
    foot
    waybar
    wofi
  ];
}
