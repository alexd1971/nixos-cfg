{ pkgs, ... }:

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

  environment.systemPackages = with pkgs; [
    swayidle
    swaylock

    foot
    waybar
    wofi
  ];
}
