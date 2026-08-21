{
  # Desktop is split by subsystem so headless hosts can skip the whole directory.
  imports = [
    ./audio.nix
    ./fonts.nix
    ./sway.nix
    ./wayland.nix
  ];
}
