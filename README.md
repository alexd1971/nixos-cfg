# nixos-cfg

Minimal modular NixOS flake intended for installation with `nixos-anywhere`.

## Install example

```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake .#dell-inspiron \
  root@TARGET_HOST
```
