{
  config,
  lib,
  ...
}:
let
  hasSwap = config.local.install.swapSize != null;
in
{
  config = lib.mkMerge [
    {
      services.power-profiles-daemon.enable = true;

      services.logind = {
        settings.Login.HandleLidSwitch = lib.mkIf hasSwap "suspend-then-hibernate";
        settings.Login.HandleLidSwitchExternalPower = "ignore";
      };
    }
    (lib.mkIf hasSwap {
      boot.resumeDevice = "/dev/disk/by-partlabel/disk-main-swap";

      systemd.sleep.settings.Sleep = {
        AllowHibernation = "yes";
        AllowSuspendThenHibernate = "yes";
        HibernateMode = "platform shutdown";
        HibernateState = "disk";
      };
    })
  ];
}