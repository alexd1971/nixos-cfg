{
  # Common modules are imported by every host; keep host-specific choices elsewhere.
  imports = [
    ./boot.nix
    ./desktop
    ./hardware.nix
    ./home-manager.nix
    ./localization.nix
    ./nix.nix
    ./networking.nix
    ./packages.nix
    ./power.nix
    ./security.nix
    ./users.nix
  ];

  # Do not change after install unless you have read the NixOS release notes.
  system.stateVersion = "26.05";
}
