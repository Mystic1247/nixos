# users/mystic/system.nix
#
# NixOS-level account definition for the "mystic" user.
# This is the part that runs as root / configures the OS user entry.
# Home Manager config lives alongside this in home.nix.

{ pkgs, ... }:

{
  users.users.mystic = {
    isNormalUser = true;
    description  = "Mystic";
    extraGroups  = [ "wheel" "networkmanager" "podman" ];
    shell        = pkgs.zsh;
  };

  programs.zsh.enable = true;
}
