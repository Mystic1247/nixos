# modules/core/users.nix
#
# Shared user-account baseline. Individual user accounts and their
# Home Manager configs are declared in users/<name>/ and wired in by mkHost.

{ ... }:

{
  security.sudo.wheelNeedsPassword = true;
}
