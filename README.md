# nixos-cfg

Minimal modular NixOS flake intended for installation with `nixos-anywhere`.

## Install example

```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake .#dell-inspiron \
  nixos@TARGET_HOST
```

The same install flow is available as a local flake app:

```bash
nix run .#remote-install -- dell-inspiron TARGET_HOST
```

After the machine is installed and SSH is available for `alexey`, apply changes remotely with:

```bash
nix run .#remote-switch -- dell-inspiron TARGET_HOST
```
