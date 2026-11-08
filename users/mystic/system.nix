# users/mystic/system.nix
#
# The NixOS side of the "mystic" account: login, groups and shell.
# Home Manager settings (dotfiles, apps) are in home/.

{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Some groups only exist when the feature behind them is enabled on the host
  # (e.g. keyd). Listing only the ones that exist avoids dangling group names.
  ifTheyExist = groups: lib.filter (group: config.users.groups ? ${group}) groups;
in
{
  users.users.mystic = {
    isNormalUser = true;
    description = "Mystic";
    extraGroups = [
      "wheel"
    ]
    ++ ifTheyExist [
      "networkmanager"
      "podman"
      "input"
      "keyd"
    ];

    # fish is not POSIX-compatible, so it is only a login shell for this user.
    # root and system scripts keep using bash.
    shell = pkgs.fish;

    # Required before profiles/server.nix can be used (it disables passwords):
    # openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAA..." ];
  };

  # Needed so fish is listed in /etc/shells and gets NixOS's environment setup.
  # The user-level fish config is in home/shell/.
  programs.fish.enable = true;

  # Where this repo lives, so `nh os switch` needs no path argument.
  programs.nh.flake = "/home/mystic/nixos";
}
