{ pkgs, ... }:

{
  services.printing = {
    enable = true;
    # CUPS only finds drivers listed here; having them in systemPackages is not enough.
    drivers = [ pkgs.pantum-driver ];
  };

  # Network printer discovery (mDNS / Bonjour).
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
