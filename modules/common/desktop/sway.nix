{ pkgs, ... }:

{
  # Enable the system Sway wrapper so sessions get the right portals and GTK env.
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # Apply the same idle/lock policy to every Home Manager user on desktop hosts.
  home-manager.sharedModules = [
    ../../../home/common/desktop-theme.nix
    ../../../home/common/hardware-keys.nix
    ../../../home/common/notifications.nix
    ../../../home/common/removable-media.nix
    ../../../home/common/sway-power.nix
    ../../../home/common/walker.nix
    ../../../home/common/waybar.nix
    ../../../home/common/yazi.nix
  ];

  # Home Manager installs swaylock, but PAM auth must be enabled system-wide.
  security.pam.services.swaylock = { };

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
