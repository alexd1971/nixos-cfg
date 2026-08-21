{ pkgs, ... }:

{
  # vim is the fallback editor available before Home Manager user config is active.
  environment.variables.EDITOR = "vim";

  # Small rescue/debugging toolbox intentionally available system-wide.
  environment.systemPackages = with pkgs; [
    # Editors
    vim

    # Shell basics
    file
    less
    tree
    which

    # Archiving
    unzip
    zip

    # Search
    ripgrep
    fd

    # Downloads / HTTP diagnostics
    curl
    wget

    # DNS diagnostics
    dnsutils

    # Network diagnostics
    inetutils
    iputils
    nmap
    tcpdump
    traceroute

    # Process / system diagnostics
    htop
    lsof

    # Hardware diagnostics
    pciutils
    smartmontools
    usbutils
  ];
}
