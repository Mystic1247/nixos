# modules/core
#
# Baseline applied to EVERY host by mkHost, whatever its profile.
# Anything role-specific (desktop, laptop, server) belongs in modules/features/.

{ ... }:

{
  imports = [
    ./boot.nix
    ./hardware.nix
    ./locale.nix
    ./networking.nix
    ./nix.nix
    ./packages.nix
    ./security.nix
  ];
}
