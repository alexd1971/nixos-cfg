{ pkgs, ... }:

{
  nixpkgs.overlays = [
    (_final: prev: {
      sushi = prev.sushi.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace src/ui/mainWindow.js \
            --replace-fail "        this.set_titlebar(this._titlebar);" \
                           "        this.set_decorated(false);"
        '';
      });
    })
  ];

  # Enable the system Sway wrapper so sessions get the right portals and GTK env.
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # Apply the same idle/lock policy to every Home Manager user on desktop hosts.
  home-manager.sharedModules = [
    ../../../home/common/bluetooth.nix
    ../../../home/common/desktop-theme.nix
    ../../../home/common/hardware-keys.nix
    ../../../home/common/mime-apps.nix
    ../../../home/common/notifications.nix
    ../../../home/common/removable-media.nix
    ../../../home/common/sway.nix
    ../../../home/common/sway-power.nix
    ../../../home/common/thunar.nix
    ../../../home/common/walker.nix
    ../../../home/common/wallpaper.nix
    ../../../home/common/waybar.nix
    ../../../home/common/yazi.nix
  ];

  # Home Manager installs swaylock, but PAM auth must be enabled system-wide.
  security.pam.services.swaylock = { };

  # Sushi uses a D-Bus activated NautilusPreviewer process. Register its session
  # service file system-wide so it is visible from Sway user sessions.
  services.dbus.packages = [ pkgs.sushi ];

  # Session tools used by the Home Manager Sway config.
  environment.systemPackages = with pkgs; [
    swayidle
    swaylock

    adwaita-icon-theme
    nordzy-icon-theme

    foot
    waybar
  ];
}
