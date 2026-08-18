{
  config,
  lib,
  ...
}:
let
  cfg = config.local.install;
  installDisk = cfg.disk;
  swapSize = cfg.swapSize;
  hasSwap = swapSize != null;
in
{
  options.local.install = {
    disk = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/dev/nvme0n1";
      description = "Target disk for nixos-anywhere installation.";
    };

    swapSize = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "16G";
      description = "Optional swap partition size. If null, no swap partition is created.";
    };
  };

  config = {
    assertions = [
      {
        assertion = installDisk != null && installDisk != "";
        message = "local.install.disk must point to the target installation disk, for example /dev/nvme0n1 or /dev/sda.";
      }
    ];

    disko.devices = {
      disk.main = {
        type = "disk";
        device = installDisk;

        content = {
          type = "gpt";

          partitions =
            {
              ESP = {
                priority = 1;
                size = "512M";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [
                    "umask=0077"
                  ];
                };
              };

              root = {
                priority = 3;
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                };
              };
            }
            // lib.optionalAttrs hasSwap {
              swap = {
                priority = 2;
                size = swapSize;
                content = {
                  type = "swap";
                };
              };
            };
        };
      };
    };
  };
}
