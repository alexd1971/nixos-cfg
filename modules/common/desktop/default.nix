{
  # Desktop is split by subsystem so headless hosts can skip the whole directory.
  imports = [
    ./apps.nix
    ./audio.nix
    ./fonts.nix
    ./greeter.nix
    ./sway.nix
    ./wayland.nix
  ];
}
