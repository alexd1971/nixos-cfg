{ config, lib, ... }:
let
  hasSwap = config.local.install.swapSize != null;
in
{
  config = lib.mkMerge [
    {
      # Let firmware/platform profiles handle laptop performance and battery tradeoffs.
      services.power-profiles-daemon.enable = true;

      services.logind = {
        settings.Login.HandlePowerKey = "ignore";
        settings.Login.HandlePowerKeyLongPress = "poweroff";

        # Only request suspend-then-hibernate when a resume-capable swap exists.
        settings.Login.HandleLidSwitch = lib.mkIf hasSwap "suspend-then-hibernate";
        settings.Login.HandleLidSwitchExternalPower = "ignore";
      };
    }
    (lib.mkIf hasSwap {
      # Disk-backed hibernation is enabled only together with configured swap.
      systemd.sleep.settings.Sleep = {
        AllowHibernation = "yes";
        AllowSuspendThenHibernate = "yes";
        HibernateMode = "platform shutdown";
        HibernateState = "disk";
      };
    })
  ];
}
