{
  # System-wide locale stays at the NixOS default; users set personal locale
  # preferences in their Home Manager configs.
  i18n.supportedLocales = [
    "C.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
    "ru_RU.UTF-8/UTF-8"
  ];

  time.timeZone = "Europe/Moscow";
}
