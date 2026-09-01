{ pkgs, ... }:

{
  # Graphical applications and desktop tools available to every local user.
  environment.systemPackages = with pkgs; [
    # Everyday applications
    # Web browser.
    firefox
    # Mail, calendar, and RSS client.
    thunderbird

    # Office
    # Full office suite for documents, spreadsheets, and presentations.
    libreoffice-qt6
    # Spell checking engine used by office and text-capable applications.
    hunspell
    # English spell checking dictionary.
    hunspellDicts.en_US
    # Russian spell checking dictionary.
    hunspellDicts.ru_RU

    # Viewers / media
    # PDF and document viewer.
    evince
    # Lightweight calendar popup for Waybar.
    gsimplecal
    # Image viewer.
    imv
    # Video and audio player.
    mpv

    # Graphics
    # Raster image editor.
    gimp
    # Vector graphics editor.
    inkscape
    # Digital painting application.
    krita

    # Files / archives
    # Graphical archive manager for zip, tar, 7z and similar formats.
    file-roller

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
