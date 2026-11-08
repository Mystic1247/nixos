# The hostname is set by mkHost from the flake attribute name.

{ ... }:

{
  networking.networkmanager.enable = true;
}
