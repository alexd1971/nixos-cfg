{ inputs }:

{
  name,
  system ? "x86_64-linux",
  install,
  modules ? [ ],
}:

inputs.nixpkgs.lib.nixosSystem {
  inherit system;

  specialArgs = { inherit inputs; };

  modules = [
    # External modules provide the option trees consumed by local modules below.
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    ../modules/common
    ../modules/disko
    {
      networking.hostName = name;
      local.install = install;
    }
  ]
  ++ modules;
}
