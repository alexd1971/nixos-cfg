{ pkgs, ... }:

{
  # Prefer Wayland backends while keeping X11 fallback where toolkits support it.
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
    MOZ_ENABLE_WAYLAND = "1";
    SDL_VIDEODRIVER = "wayland";
  };

  # Tools expected in a minimal wlroots desktop: clipboard, screenshots, and MIME opening.
  environment.systemPackages = with pkgs; [
    wl-clipboard

    grim
    slurp

    xdg-utils

    pavucontrol
  ];

  # Portals are needed for screenshots, file pickers, and screen sharing under Sway.
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk xdg-desktop-portal-wlr ];
  };
}
