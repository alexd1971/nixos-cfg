{ pkgs, ... }:

{
  users.users.alexey = {
    isNormalUser = true;
    # Bootstrap password for first local login. Change it immediately with `passwd`.
    initialPassword = "admin";
    shell = pkgs.bashInteractive;

    extraGroups = [
      "wheel"
      "networkmanager"
    ];

    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6bKAgMtJswSSeyUZTgM88QLnnTs89UADyacV7TBE470V8mgcYaX63C4UeYN0E2Z/avE777pit/9+upU7jkzHrQ5brzHB6kuGRN9MTdL0alf5UOMT00XqPzBkaN+CSDkdNy8SCvDLmr6GkyuWi9WJgjGP+zdbjmRvG4i/dFfUVMTGAitXEZJpIBUrf5AzNU/MmFTWHKfMUMDSvQEflH1q/9/inknNBDeI+lQqrxPjfjY7wi6rTS5DtMGbMBGfeK1jtfffiUumFVPfQD93KJqx7Dq+57AdQLNlsmHVwjZoHNF4qFkcTi5yUWnFdNSnCN8TOqC5Y6I7+bXumU6I9Xu4poDNVQBFDkzdfpJXKOHYh3uwoawChVcg8TS1Ph1bIAKoPFd65FvoYlKddV5yKCWr9tyX2IDiOr65NwchTtodsT+PC3WqH8b5oAsLgh/JQbg5Oa8LR0Q3YCGILc1pSJE8kjFKrbrXhM9Zsdt6HoC3hQ++yVlvgmVXA5xXGSxYwsNfqTN8SkUtIFsVQ7d12PecI3NyaW4oFhT2WoZvnnCPkGcxp2OCrHuG/LeJ6b98way7pKfH05IqdKvZgJwcmzAZDyp1V/P/pqi1LS43JSqag8VCUqK8Iq2zIBrcTvGIZWYJOyymcf9lwhuXD3Mg/ZEItUFkEKxImzwW4T4vEeGrB8w=="
    ];
  };
}
