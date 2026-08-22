{
  description = "Modular NixOS configurations installable with nixos-anywhere";

  inputs = {
    # Track unstable once and make integrations reuse the same nixpkgs.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    elephant = {
      url = "github:abenz1267/elephant";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    walker = {
      url = "github:abenz1267/walker";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.elephant.follows = "elephant";
    };
  };

  outputs =
    inputs@{ ... }:
    {
      formatter = {
        x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;
        aarch64-linux = inputs.nixpkgs.legacyPackages.aarch64-linux.nixfmt-tree;
      };

      # Host entries are kept as separate modules so nixos-anywhere can target them by name.
      nixosConfigurations = {
        dell-inspiron = import ./hosts/dell-inspiron { inherit inputs; };
      };
    };
}
