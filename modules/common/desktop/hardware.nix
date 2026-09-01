{ pkgs, ... }:

{
  # UDisks/GVfs provide storage integration for terminal file managers and portals.
  services.udisks2.enable = true;
  services.gvfs.enable = true;

  # UPower exposes battery and device power state to desktop widgets and apps.
  services.upower.enable = true;

  # fwupd keeps supported device firmware updateable through LVFS.
  services.fwupd.enable = true;

  # Bluetooth stack plus a graphical agent/tray manager for pairing devices.
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # Printer/scanner support, including driverless network and USB IPP devices.
  services.printing.enable = true;
  services.system-config-printer.enable = true;
  services.ipp-usb.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.sane-airscan ];
  };

  # Useful hardware control/status tools for a minimal Wayland desktop.
  environment.systemPackages = with pkgs; [
    gnome-disk-utility
    simple-scan
  ];
}
