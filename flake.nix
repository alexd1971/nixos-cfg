{
  description = "Modular NixOS configurations installable with nixos-anywhere";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ ... }:
    {
      nixosConfigurations = {
        dell-inspiron = import ./hosts/dell-inspiron {
          inherit inputs;
        };
      };
    };
}
