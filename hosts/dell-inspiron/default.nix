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
      networking.hostName = "dell-inspiron";

      local.install = {
        disk = "/dev/sda";
        swapSize = "10G";
      };

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";
      home-manager.users.alexey = import ../../home/alexey;
    }
  ];
}
