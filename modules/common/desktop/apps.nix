{ pkgs, ... }:

{
  # Graphical applications and desktop tools available to every local user.
  environment.systemPackages = with pkgs; [
    # Everyday applications
    # Web browser.
    firefox

    # Viewers / media
    # PDF and document viewer.
    evince
    # Lightweight calendar popup for Waybar.
    gsimplecal
    # Image viewer.
    imv
    # Video and audio player.
    mpv

    # Desktop controls used from Sway/Waybar keybindings.
    # Backlight brightness control.
    brightnessctl
    # NetworkManager menu for dmenu-compatible launchers.
    networkmanager_dmenu
    # NetworkManager tray applet and connection editor.
    networkmanagerapplet
    # PulseAudio/PipeWire volume mixer.
    pavucontrol
    # MPRIS media control for keyboard play/pause/next/previous keys.
    playerctl
    # GTK pinentry dialog for password prompts.
    pinentry-gnome3
  ];
}
