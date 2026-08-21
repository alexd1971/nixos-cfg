{
  nix.settings = {
    # Required for flakes and the modern nix command used by this repository.
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
    # Allow wheel users to operate local Nix without switching to root.
    trusted-users = [
      "root"
      "@wheel"
    ];
  };

  # Keep the laptop store from growing indefinitely.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
}
