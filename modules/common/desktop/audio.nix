{
  # rtkit lets PipeWire request realtime scheduling without running as root.
  security.rtkit.enable = true;

  # PipeWire provides native audio plus PulseAudio compatibility for desktop apps.
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
