# Graphical, silent boot: Plymouth splash and no kernel/udev chatter.
# For graphical machines only; a server wants to see its boot messages.

{ ... }:

{
  boot.plymouth = {
    enable = true; # also adds the "splash" kernel parameter
    theme = "bgrt"; # manufacturer logo from the firmware
  };

  boot.consoleLogLevel = 0; # sets loglevel=0; only add `loglevel=` params through this option
  boot.kernelParams = [
    "quiet"
    "boot.shell_on_fail" # still get a shell if the root filesystem fails to mount
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
  ];
}
