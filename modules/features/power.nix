# Laptop power management.

{ config, lib, ... }:

{
  # Periodic TRIM for SSDs.
  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  services.thermald.enable = true; # Intel CPUs only

  # GNOME enables power-profiles-daemon (the Power Mode switch in Settings).
  # auto-cpufreq is an alternative that cannot run next to it, so turning it on
  # below switches PPD off automatically.
  # TODO: decide between the two, then delete the loser.
  services.auto-cpufreq = {
    enable = false;
    settings = {
      battery = {
        governor = "powersave";
        turbo = "auto";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };
  };
  services.power-profiles-daemon.enable = lib.mkIf config.services.auto-cpufreq.enable false;
}
