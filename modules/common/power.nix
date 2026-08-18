{ config, lib, ... }:
let
  hasSwap = config.local.install.swapSize != null;
in
{
  config = lib.mkIf hasSwap {
    boot.resumeDevice = "/dev/disk/by-partlabel/disk-main-swap";

    systemd.sleep.settings.Sleep = {
      AllowHibernation = "yes";
      AllowSuspendThenHibernate = "yes";
      HibernateMode = "platform shutdown";
      HibernateState = "disk";
    };
  };
}
