{
  imports = [
    ./boot.nix
    ./desktop
    ./hardware.nix
    ./localization.nix
    ./nix.nix
    ./networking.nix
    ./packages.nix
    ./power.nix
    ./security.nix
    ./users.nix
  ];

  system.stateVersion = "26.05";
}
