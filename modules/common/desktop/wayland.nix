{ pkgs, ... }:

{
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
  };

  environment.systemPackages = with pkgs; [
    # Wayland clipboard
    wl-clipboard

    # Wayland screenshots
    grim
    slurp

    # Desktop integration
    xdg-utils
  ];

  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };
}
