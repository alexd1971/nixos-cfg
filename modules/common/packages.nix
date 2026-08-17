{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Editors
    vim

    # Version control
    git

    # DNS diagnostics
    dnsutils

    # Network diagnostics
    inetutils
    iputils
    nmap
    tcpdump
    traceroute

    # Hardware diagnostics
    pciutils
    usbutils
  ];
}
