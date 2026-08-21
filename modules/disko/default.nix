{ config, lib, ... }:
let
  cfg = config.local.install;
  installDisk = cfg.disk;
  swapSize = cfg.swapSize;
  hasSwap = swapSize != null;
  luks = cfg.luks;

  # One switch controls the whole install layout: either root and swap are encrypted or neither is.
  rootContent = if luks then {
    type = "luks";
    name = "root";
    settings = { allowDiscards = true; };
    content = {
      type = "filesystem";
      format = "ext4";
      mountpoint = "/";
    };
  } else {
    type = "filesystem";
    format = "ext4";
    mountpoint = "/";
  };

  # Encrypted swap is a stable LUKS device so hibernation can resume from it.
  swapContent = if luks then {
    type = "luks";
    name = "swap";
    settings = {
      allowDiscards = true;
      # After systemd-cryptenroll, systemd opens swap from TPM2 without a second passphrase.
      crypttabExtraOpts = [ "tpm2-device=auto" ];
    };
    content = {
      type = "swap";
      resumeDevice = true;
    };
  } else {
    type = "swap";
    resumeDevice = true;
  };
in {
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
      description =
        "Optional swap partition size. If null, no swap partition is created.";
    };

    luks = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description =
        "Encrypt the root partition with LUKS. The LUKS password is set interactively during nixos-anywhere installation.";
    };
  };

  config = {
    assertions = [{
      assertion = installDisk != null && installDisk != "";
      message =
        "local.install.disk must point to the target installation disk, for example /dev/nvme0n1 or /dev/sda.";
    }];

    disko.devices = {
      disk.main = {
        type = "disk";
        device = installDisk;

        content = {
          type = "gpt";

          partitions = {
            ESP = {
              priority = 1;
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                # Keep EFI files readable only by root; /boot itself is intentionally unencrypted.
                mountOptions = [ "umask=0077" ];
              };
            };

            root = {
              priority = 3;
              size = "100%";
              content = rootContent;
            };
          } // lib.optionalAttrs hasSwap {
            swap = {
              priority = 2;
              size = swapSize;
              content = swapContent;
            };
          };
        };
      };
    };
  };
}
