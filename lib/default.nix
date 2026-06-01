# lib/default.nix
# Exports all lib helpers. Import this in flake.nix as:
#   lib = import ./lib { inherit (nixpkgs) lib; inherit nixpkgs home-manager inputs; };

{ nixpkgs, home-manager, inputs, ... }:

{
  mkHost = import ./mkHost.nix { inherit nixpkgs home-manager inputs; };
}
