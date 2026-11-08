{ ... }:

{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General = {
      Enable = "Source,Sink,Media,Socket";
      Experimental = true;
    };
  };

  services.blueman = {
    enable = true;
    # withApplet = false; # TODO: temp fix
  };

  # Bluetooth audio policy for WirePlumber.
  # Only A2DP (high-quality stereo) is offered, and the headset profile is never
  # switched to automatically. Side effect: a Bluetooth headset's microphone
  # (HSP/HFP) is unavailable. Remove this block if you need it.
  services.pipewire.wireplumber.extraConfig."10-bluez" = {
    "monitor.bluez.properties"."bluez5.roles" = [
      "a2dp_sink"
      "a2dp_source"
    ];
    "wireplumber.settings"."bluetooth.autoswitch-to-headset-profile" = false;
  };
}
