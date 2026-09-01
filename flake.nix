{
  description = "Modular NixOS configurations installable with nixos-anywhere";

  inputs = {
    # Track unstable once and make integrations reuse the same nixpkgs.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    elephant = {
      url = "github:abenz1267/elephant";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    walker = {
      url = "github:abenz1267/walker";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.elephant.follows = "elephant";
    };
  };

  outputs =
    inputs@{ self, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = inputs.nixpkgs.lib.genAttrs systems;
    in
    {
      formatter = forAllSystems (system: inputs.nixpkgs.legacyPackages.${system}.nixfmt-tree);

      apps = forAllSystems (
        system:
        let
          pkgs = inputs.nixpkgs.legacyPackages.${system};

          remoteInstall = pkgs.writeShellApplication {
            name = "nixos-remote-install";
            runtimeInputs = [ pkgs.nixos-anywhere ];
            text = ''
              usage() {
                cat <<'USAGE'
              Usage:
                nix run .#remote-install -- <host> <ip-or-hostname> [ssh-user]

              Examples:
                nix run .#remote-install -- dell-inspiron 192.168.31.75
                nix run .#remote-install -- dell-inspiron 192.168.31.75 nixos

              Defaults:
                ssh-user: nixos
              USAGE
              }

              if [[ $# -lt 2 || $# -gt 3 ]]; then
                usage
                exit 2
              fi

              host="$1"
              target="$2"
              user="''${3:-nixos}"

              exec nixos-anywhere --flake "${self}#$host" "$user@$target"
            '';
          };

          remoteSwitch = pkgs.writeShellApplication {
            name = "nixos-remote-switch";
            runtimeInputs = [ pkgs.nixos-rebuild ];
            text = ''
              usage() {
                cat <<'USAGE'
              Usage:
                nix run .#remote-switch -- <host> <ip-or-hostname> [ssh-user]

              Examples:
                nix run .#remote-switch -- dell-inspiron 192.168.31.75
                nix run .#remote-switch -- dell-inspiron 192.168.31.75 alexey

              Defaults:
                ssh-user: alexey
              USAGE
              }

              if [[ $# -lt 2 || $# -gt 3 ]]; then
                usage
                exit 2
              fi

              host="$1"
              target="$2"
              user="''${3:-alexey}"
              target_host="$user@$target"
              flake_ref="${self}#$host"

              exec nixos-rebuild switch \
                --flake "$flake_ref" \
                --target-host "$target_host" \
                --elevate=sudo \
                --ask-elevate-password
            '';
          };
        in
        {
          remote-install = {
            type = "app";
            program = "${remoteInstall}/bin/nixos-remote-install";
          };

          remote-switch = {
            type = "app";
            program = "${remoteSwitch}/bin/nixos-remote-switch";
          };
        }
      );

      # Host entries are kept as separate modules so nixos-anywhere can target them by name.
      nixosConfigurations = {
        dell-inspiron = import ./hosts/dell-inspiron { inherit inputs; };
      };
    };
}
