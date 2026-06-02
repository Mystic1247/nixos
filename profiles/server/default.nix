# profiles/server/default.nix
#

{ pkgs, ... }:

{
  imports = [
    ../../modules/features/packages.nix
    ../../modules/features/virt.nix
  ];

  services.xserver.enable = false;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = false;
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  system.autoUpgrade = {
    enable = true;
    flake = "github:Mystic1247/nixos-config";
    flags = [
      "--update-input"
      "nixpkgs"
    ];
    dates = "04:00";
    randomizedDelaySec = "30min";
  };
}
