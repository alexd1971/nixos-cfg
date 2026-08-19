{ ... }:
{
  imports = [
    ./git.nix
    ./sway.nix
  ];

  home.username = "alexey";
  home.homeDirectory = "/home/alexey";

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}