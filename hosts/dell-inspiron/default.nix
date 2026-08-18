{
  inputs,
  system ? "x86_64-linux",
}:
inputs.nixpkgs.lib.nixosSystem {
  inherit system;

  specialArgs = {
    inherit inputs;
  };

  modules = [
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    ../../modules/common
    ../../modules/disko
    ./hardware.nix
    {
      nixpkgs.hostPlatform = system;

      networking.hostName = "dell-inspiron";

      local.install = {
        disk = "/dev/sda";

        # Example: swapSize = "16G";
        swapSize = "10G";
      };

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.alexey = import ../../home/alexey;
    }
  ];
}
