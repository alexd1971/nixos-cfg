{ inputs }:
let
  mkHost = import ../mk-host.nix { inherit inputs; };
in
mkHost {
  name = "dell-inspiron";

  # Installation-specific knobs used by modules/disko to build the disk layout.
  install = {
    disk = "/dev/sda";
    swapSize = "10G";
    luks = true;
  };

  modules = [ ./hardware.nix ];
}
