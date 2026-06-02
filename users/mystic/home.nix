# users/mystic/home.nix
#
# Home Manager root for the "mystic" user.
# This is imported by mkHost and wired into home-manager.users.mystic.

{ inputs, ... }:

{
  home.username = "mystic";
  home.homeDirectory = "/home/mystic";

  home.stateVersion = "25.05";

  imports = [
    ../../home/mystic/core
    ../../home/mystic/features
  ];
}
