{ inputs, ... }:

{
  # Keep user configuration in Home Manager while sharing the system package set.
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "backup";
  home-manager.users.alexey = {
    imports = [
      inputs.walker.homeManagerModules.default
      ../../home/alexey
    ];
  };
}
