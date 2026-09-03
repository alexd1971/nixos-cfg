{ ... }: {
  # User config is split by application to keep system and home concerns separate.
  imports = [
    ./apps.nix
    ./git.nix
    ./localization.nix
  ];

  # Home Manager needs these fixed paths to manage files for this user.
  home.username = "alexey";
  home.homeDirectory = "/home/alexey";

  # Match the NixOS state version; do not bump automatically.
  home.stateVersion = "26.05";

  # Expose the home-manager command in the user environment.
  programs.home-manager.enable = true;
}
