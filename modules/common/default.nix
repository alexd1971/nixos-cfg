{
  imports = [
    ./boot.nix
    ./desktop
    ./hardware.nix
    ./nix.nix
    ./packages.nix
    ./power.nix
    ./networking.nix
    ./security.nix
    ./users.nix
  ];

  system.stateVersion = "26.05";
}
