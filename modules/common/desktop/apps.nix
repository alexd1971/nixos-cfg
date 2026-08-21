{ pkgs, ... }:

{
  # Graphical applications and desktop tools available to every local user.
  environment.systemPackages = with pkgs; [
    # Everyday applications
    firefox
    thunar

    # Viewers / media
    evince
    imv
    mpv

    # Desktop controls used from Sway/Waybar keybindings.
    brightnessctl
    networkmanager_dmenu
    networkmanagerapplet
    pavucontrol
    pinentry-gnome3
  ];
}
