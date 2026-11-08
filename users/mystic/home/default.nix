# users/mystic/home
#
# Home Manager configuration for "mystic", imported by mkHost on every host.
# (username and home directory are derived from the NixOS account.)
#
#   shell/    fish, prompt and command-line tools
#   desktop/  graphical apps and their settings
#   git.nix, ssh.nix

{ ... }:

{
  imports = [
    ./shell
    ./desktop
    ./git.nix
    ./ssh.nix
  ];

  # Set when Home Manager was first used. Do NOT change it to follow upgrades.
  home.stateVersion = "25.05";
}
