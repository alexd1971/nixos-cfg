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
    ../../modules/common
    ../../modules/disko
    {
      nixpkgs.hostPlatform = system;

      networking.hostName = "dell-inspiron";

      local.install = {
        disk = "/dev/sda";

        # Example: swapSize = "16G";
        swapSize = "10G";
      };
    }
  ];
}
