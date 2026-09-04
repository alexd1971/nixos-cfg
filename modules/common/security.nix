{
  # Wheel still requires the local password, so the bootstrap password must be changed.
  security.sudo.wheelNeedsPassword = true;
  # Desktop components use polkit for power and NetworkManager actions.
  security.polkit.enable = true;
  # Some desktop tools, e.g. Mission Center, use pkexec for privileged actions.
  security.polkit.enablePkexecWrapper = true;
}
