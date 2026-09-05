{ pkgs, ... }:

{
  # Shared visual defaults for Wayland desktop users.
  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 30;
  };

  gtk = {
    enable = true;
    colorScheme = "dark";

    theme = {
      package = pkgs.nordic;
      name = "Nordic-bluish-accent";
    };

    iconTheme = {
      package = pkgs.nordzy-icon-theme;
      name = "Nordzy-dark";
    };

    font = {
      name = "DejaVu Sans";
      size = 13;
    };

  };

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style = {
      package = pkgs.adwaita-qt;
      name = "adwaita-dark";
    };
  };
}
