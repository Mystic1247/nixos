# profiles/server.nix
#
# Headless machine: no desktop, key-only SSH, unattended updates.
# (No host uses this yet.)
#
# Before using it, give the user an SSH key, or password login being disabled
# below will lock you out. In users/<name>/system.nix:
#   users.users.<name>.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAA..." ];

{ ... }:

{
  imports = [ ../modules/features/virt.nix ];

  services.openssh = {
    enable = true; # also opens port 22 in the firewall
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = false;
    };
  };

  system.autoUpgrade = {
    enable = true;
    flake = "github:Mystic1247/nixos-config";
    flags = [
      "--update-input"
      "nixpkgs"
      # The flake is remote, so the refreshed lock file can't be written back.
      "--no-write-lock-file"
    ];
    dates = "04:00";
    randomizedDelaySec = "30min";
  };
}
