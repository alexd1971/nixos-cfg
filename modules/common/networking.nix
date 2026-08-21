{
  # NetworkManager is the interactive network stack for the laptop/desktop session.
  networking.networkmanager.enable = true;

  # Keep the default firewall tight; SSH is the only remote bootstrap entry point.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  # Remote access is key-only; the bootstrap password is only for local login/sudo.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };
}
