{
  imports = [
    ./boot.nix
    ./hardware.nix
    ./nix.nix
    ./networking.nix
    ./security.nix
    ./users.nix
  ];

  system.stateVersion = "26.05";
}
