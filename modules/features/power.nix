{ pkgs, ... }:

{
  services.auto-cpufreq = {
    enable = false; # TODO: true
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

  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  services.thermald.enable = true;
}
