# PipeWire audio stack (replaces PulseAudio/JACK/ALSA servers).
# Bluetooth audio tuning lives in bluetooth.nix.

{ ... }:

{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true; # 32-bit games / Wine
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };
}
