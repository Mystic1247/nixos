# modules/features/umbriel.nix
# This file only exists to install and enable Umbriel, configuration is done per-user in users/<username>/home/desktop/umbriel.nix.

{ inputs, ... }:

{
  imports = [ inputs.umbriel.nixosModules.default ];

  programs.umbriel.enable = true;
}
