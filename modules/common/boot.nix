{
  # systemd initrd is needed for TPM2-backed LUKS unlock through crypttab options.
  boot.initrd.systemd.enable = true;
}
