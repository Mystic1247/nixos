# hosts/spectre/default.nix
#
# HP Spectre x360 — convertible laptop.
# Role profile: laptop (see profiles/laptop)
# User(s): mystic (see users/mystic)
#
# Reminder: only put things here that are unique to this specific machine.
# Shared laptop behaviour lives in profiles/laptop/.

{ ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "spectre";
  time.timeZone = "Asia/Singapore";

  services.logind.settings = {
    Login = {
      HandleLidSwitch = "ignore";
      HandleLidSwitchExternalPower = "ignore";
      HandleLidSwitchDocked = "ignore";
      HandlePowerKey = "suspend";
    };
  };

  system.stateVersion = "25.05";
}
