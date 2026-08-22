{ pkgs, ... }:

{
  # Common hosts boot through UEFI, so systemd-boot manages the ESP mounted at /boot.
  boot.loader.systemd-boot.enable = true;
  # Hide the boot menu during normal boots; hold a bootloader key such as Space to show it.
  boot.loader.timeout = 0;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  # systemd initrd is needed for TPM2-backed LUKS unlock through crypttab options.
  boot.initrd.systemd.enable = true;

  # Keep boot visually quiet and show a NixOS-branded Plymouth splash instead of kernel logs.
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  boot.kernelParams = [
    "quiet"
    "splash"
    "loglevel=0"
    "udev.log_level=0"
    "rd.udev.log_level=0"
    "rd.systemd.show_status=false"
    "systemd.show_status=false"
    "vt.global_cursor_default=0"
  ];

  boot.plymouth = {
    enable = true;
    logo = "${pkgs.nixos-icons}/share/icons/hicolor/256x256/apps/nix-snowflake.png";
    theme = "bgrt";
  };
}
