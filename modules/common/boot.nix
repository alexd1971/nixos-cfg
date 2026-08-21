{
  # systemd initrd is needed for TPM2-backed LUKS unlock through crypttab options.
  boot.initrd.systemd.enable = true;

  # The install layout mounts the EFI System Partition at /boot.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
}
