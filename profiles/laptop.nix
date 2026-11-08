# profiles/laptop.nix
#
# A workstation that runs on battery: adds power management and sets lid and
# power-button behaviour. Hosts override the defaults below where they differ
# (e.g. hosts/spectre keeps running with the lid closed).

{ lib, ... }:

{
  imports = [
    ./workstation.nix
    ../modules/features/power.nix
  ];

  services.logind.settings.Login = lib.mapAttrs (_: lib.mkDefault) {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "suspend";
    HandlePowerKey = "suspend";
  };
}
