# hosts/spectre
#
# HP Spectre x360 (convertible). Profile: laptop. Only machine-specific things
# go here; shared laptop behaviour lives in profiles/laptop.nix.

{ ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Keep running with the lid closed (overrides the laptop profile's suspend).
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  # Set when this machine was first installed. Do NOT change it to follow upgrades.
  system.stateVersion = "25.05";
}
