# hosts/t480
#
# Lenovo ThinkPad T480. Profile: laptop. Only machine-specific things go
# here; shared laptop behaviour lives in profiles/laptop.nix.

{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/features/keyd.nix
  ];

  # Media keys on the navigation cluster.
  services.keyd.keyboards.default.settings.main = {
    home = "previoussong";
    end = "playpause";
    insert = "nextsong";
  };

  # Set when this machine was first installed. Do NOT change it to follow upgrades.
  system.stateVersion = "24.11";
}
