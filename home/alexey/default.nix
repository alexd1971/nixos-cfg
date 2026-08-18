{ pkgs, ... }:

{
  home.username = "alexey";
  home.homeDirectory = "/home/alexey";

  home.packages = [
    pkgs.home-manager
  ];

  programs.home-manager.enable = true;

  home.stateVersion = "26.05";
}
