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

          remoteFacter = pkgs.writeShellApplication {
            name = "nixos-remote-facter";
            runtimeInputs = [
              pkgs.coreutils
              pkgs.openssh
              pkgs.jq
            ];
            text = ''
              usage() {
                cat <<'USAGE'
              Usage:
                nix run .#remote-facter -- <host> <ip-or-hostname> <ssh-user>

              Examples:
                nix run .#remote-facter -- dell-inspiron 192.168.31.75 alexey

              The report is written to:
                hosts/<host>/facter.json
              USAGE
              }

              if [[ $# -ne 3 ]]; then
                usage
                exit 2
              fi

              host="$1"
              target="$2"
              user="$3"

              case "$host" in
                *[!A-Za-z0-9._-]*)
                  echo "Invalid host name: $host" >&2
                  exit 2
                  ;;
              esac

              report="hosts/$host/facter.json"
              if [[ ! -d "hosts/$host" ]]; then
                echo "Unknown host directory: hosts/$host" >&2
                exit 2
              fi

              target_host="$user@$target"

              ssh_opts=(
                -F /dev/null
              )

              tmp_report="$report.tmp"
              trap 'rm -f "$tmp_report"' EXIT

              read -r -s -p "sudo password for $target_host: " sudo_password
              echo

              if ! printf '%s\n' "$sudo_password" | ssh "''${ssh_opts[@]}" "$target_host" \
                "sudo -S -p \"\" nix --extra-experimental-features 'nix-command flakes' run nixpkgs#nixos-facter -- --log-level error -o /dev/stdout" > "$tmp_report"; then
                unset sudo_password
                echo "Failed to generate facter report on $target_host" >&2
                exit 1
              fi
              unset sudo_password

              if ! jq -e 'type == "object" and length > 0' "$tmp_report" >/dev/null; then
                echo "Generated report is empty or invalid: $tmp_report" >&2
                exit 1
              fi

              mv "$tmp_report" "$report"
              trap - EXIT

              echo "Wrote $report"
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

          remote-facter = {
            type = "app";
            program = "${remoteFacter}/bin/nixos-remote-facter";
          };
        }
      );

      # Host entries are kept as separate modules so nixos-anywhere can target them by name.
      nixosConfigurations = {
        dell-inspiron = import ./hosts/dell-inspiron { inherit inputs; };
      };
    };
}
