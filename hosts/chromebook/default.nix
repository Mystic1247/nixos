# hosts/chromebook/default.nix
#
# DELL Nasher - Chromebook
# Role profile: laptop (see profiles/laptop)
# User(s): mystic (see users/mystic)
#
# Reminder: only put things here that are unique to this specific machine.
# Shared laptop behaviour lives in profiles/laptop/

{ ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "nasher";
  time.timeZone = "Asia/Singapore";

  services.logind.settings = {
    Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "suspend";
      HandleLidSwitchDocked = "suspend";
      HandlePowerKey = "suspend";
    };
  };

  services.keyd.keyboards = {
    default = {
      ids = [ "*" ];
      settings = {
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

        shift = {
          meta = "capslock";
        };
      };
    };
  };

  nixowos.enable = true;

  system.stateVersion = "25.11";
}
