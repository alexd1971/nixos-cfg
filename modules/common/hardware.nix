{
  # Needed for common laptop firmware blobs such as Wi-Fi and CPU microcode.
  hardware.enableRedistributableFirmware = true;

  # Keep SSD/NVMe/eMMC storage healthy without requiring host-specific setup.
  services.fstrim.enable = true;
}
