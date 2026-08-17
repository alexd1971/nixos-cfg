{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Editors
    vim

    # Version control
    git

    # Shell basics
    file
    less
    tree
    which

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
