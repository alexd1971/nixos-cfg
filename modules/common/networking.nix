{
  networking.nameservers = [
    "127.0.0.1"
    "::1"
  ];

  networking.networkmanager.dns = "none";
  networking.networkmanager.enable = true;

  services.dnscrypt-proxy2 = {
    enable = true;

    settings = {
      server_names = [
        "cisco-doh"
      ];

      listen_addresses = [
        "127.0.0.1:53"
        "[::1]:53"
      ];

      ipv4_servers = true;
      ipv6_servers = false;
      dnscrypt_servers = false;
      doh_servers = true;
      odoh_servers = false;

      static."cisco-doh".stamp = "sdns://AgAAAAAAAAAADDE0Ni4xMTIuNDEuMiCYZO337qhZZ1J0sPrfvSaTZamrnrp3PahnSUxalKQ33w9kb2gub3BlbmRucy5jb20KL2Rucy1xdWVyeQ";
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };
}
