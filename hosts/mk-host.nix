{ inputs }:

{
  name,
  system ? "x86_64-linux",
  install,
  modules ? [ ],
}:

let
  hostDir = ./. + "/${name}";
  facterReport = hostDir + "/facter.json";
  requireFacterReport =
    if builtins.pathExists facterReport then
      facterReport
    else
      throw ''
        Missing nixos-facter report for host '${name}'.

        Generate it with:
          nix run .#remote-facter -- ${name} <ip-or-hostname> <ssh-user>

        Expected path:
          hosts/${name}/facter.json
      '';
in

inputs.nixpkgs.lib.nixosSystem {
  inherit system;

  specialArgs = { inherit inputs; };

  modules = [
    # External modules provide the option trees consumed by local modules below.
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    ../modules/common
    ../modules/disko
    {
      networking.hostName = name;
      local.install = install;
    }
  ]
  ++ [
    {
      # Per-host report generated with:
      #   nix run .#remote-facter -- <host> <ip-or-hostname> <ssh-user>
      #
      # The built-in nixpkgs hardware.facter module configures CPU microcode,
      # firmware, graphics, storage/input initrd modules, networking hardware and
      # other detected hardware support from this report.
      hardware.facter.reportPath = requireFacterReport;
    }
  ]
  ++ modules;
}
