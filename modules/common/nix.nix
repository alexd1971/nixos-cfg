{ lib, ... }:

{
  nix.settings = {
    # Required for flakes and the modern nix command used by this repository.
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
    # Prefer mirrors of cache.nixos.org, but keep the official cache as fallback.
    substituters = lib.mkForce [
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store?priority=10"
      "https://mirrors.ustc.edu.cn/nix-channels/store?priority=20"
      "https://cache.nixos.org?priority=40"
    ];
    trusted-public-keys = lib.mkForce [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
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
