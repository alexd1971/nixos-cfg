{ inputs }:
inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";

  specialArgs = { inherit inputs; };

  modules = [
    # External modules provide the option trees consumed by local modules below.
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    ../../modules/common
    ../../modules/disko
    ./boot.nix
    ./hardware.nix
    {
      networking.hostName = "dell-inspiron";

      # Installation-specific knobs used by modules/disko to build the disk layout.
      local.install = {
        disk = "/dev/sda";
        swapSize = "10G";
        luks = true;
      };

      # Keep user configuration in Home Manager while sharing the system package set.
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";
      home-manager.users.alexey = import ../../home/alexey;
    }
  ];
}
