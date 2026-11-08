# hosts/nasher
#
# Dell Chromebook "Nasher". Profile: laptop. Only machine-specific things go
# here; shared laptop behaviour lives in profiles/laptop.nix.
#
# (The folder and flake attribute are named after the hostname, not "chromebook",
# because `nh os switch` looks up the configuration matching the hostname.)

{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/features/keyd.nix
    ../../modules/features/nixowos.nix
  ];

  # Chromebook-specific GNOME extensions (touch / tablet use).
  environment.systemPackages = with pkgs; [
    gnomeExtensions.touchpad-switcher
    gnomeExtensions.screen-rotate
    gnomeExtensions.gjs-osk
    gnomeExtensions.touchup
  ];

  # Map the Chromebook's top row of media/function keys. Hold Meta for plain
  # F-keys and the arrow-key navigation cluster.
  services.keyd.keyboards.default.settings = {
    main = {
      f1 = "back";
      f2 = "forward";
      f3 = "f5";
      f4 = "f11";
      f5 = "M-f8";
      f6 = "brightnessdown";
      f7 = "brightnessup";
      f8 = "mute";
      f9 = "volumedown";
      f10 = "volumeup";
    };

    meta = {
      f1 = "f1";
      f2 = "f2";
      f3 = "f3";
      f4 = "f4";
      f5 = "f5";
      f6 = "f6";
      f7 = "f7";
      f8 = "f8";
      f9 = "f9";
      f10 = "f10";

      left = "home";
      right = "end";
      up = "pageup";
      down = "pagedown";

      backspace = "delete";
    };

    shift.meta = "capslock";
  };

  # Set when this machine was first installed. Do NOT change it to follow upgrades.
  system.stateVersion = "25.11";
}
