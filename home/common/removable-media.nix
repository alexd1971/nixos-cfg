{ ... }:

{
  # Automatically mount removable drives in the graphical session through UDisks2.
  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "auto";
  };
}
