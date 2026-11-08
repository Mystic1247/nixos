# lib/mkHost.nix
#
# Builds one NixOS configuration out of the repo's layers. Every machine is
# assembled the same way, so adding a host never means touching this file:
#
#   modules/core/          always applied (baseline for every machine)
#   hosts/<hostname>/      this machine's hardware and its unique quirks
#   profiles/<name>.nix    a role (laptop, desktop, server) = a list of features
#   users/<name>/          the NixOS account (system.nix) and its Home Manager
#                          config (home/)
#
# Usage (see flake.nix):
#
#   nixosConfigurations.spectre = mkHost {
#     hostname = "spectre";
#     profiles = [ "laptop" ];
#     users    = [ "mystic" ];
#   };
#
# Arguments:
#   hostname     - becomes networking.hostName; must match a folder in hosts/
#   profiles     - profile names from profiles/ (without ".nix")
#   users        - user names from users/ to create and wire into Home Manager
#   extraModules - optional extra NixOS modules for one-off additions

{ inputs }:

{
  hostname,
  profiles ? [ ],
  users ? [ ],
  extraModules ? [ ],
}:

inputs.nixpkgs.lib.nixosSystem {
  specialArgs = { inherit inputs; };

  modules = [
    ../modules/core
    ../hosts/${hostname}

    # Single source of truth: the flake attribute name *is* the hostname.
    { networking.hostName = hostname; }

    inputs.home-manager.nixosModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true; # share the system's nixpkgs (and its overlays)
        useUserPackages = true;
        extraSpecialArgs = { inherit inputs; };
        backupFileExtension = "backup";
        users = inputs.nixpkgs.lib.genAttrs users (user: ../users/${user}/home);
      };
    }
  ]
  ++ map (profile: ../profiles/${profile}.nix) profiles
  ++ map (user: ../users/${user}/system.nix) users
  ++ extraModules;
}
