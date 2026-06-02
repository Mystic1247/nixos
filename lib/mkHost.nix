# lib/mkHost.nix
#
# Helper function for stamping out NixOS host configurations.
# Usage (in flake.nix):
#
#   nixosConfigurations.spectre = mkHost {
#     hostname = "spectre";
#     system   = "x86_64-linux";
#     profiles = [ "laptop" ];
#     users    = [ "mystic" ];
#   };
#
# Arguments:
#   hostname  - machine hostname; must match a folder under hosts/
#   system    - e.g. "x86_64-linux", "aarch64-linux"
#   profiles  - list of profiles from profiles/ to apply (e.g. ["laptop"])
#   users     - list of users from users/ whose HM configs to wire in
#   extraModules - optional list of extra NixOS modules to include

{
  nixpkgs,
  home-manager,
  inputs,
  ...
}:

{
  hostname,
  system ? "x86_64-linux",
  profiles ? [ ],
  users ? [ ],
  extraModules ? [ ],
}:

nixpkgs.lib.nixosSystem {
  # inherit system;
  specialArgs = { inherit inputs; };

  modules = [
    { nixpkgs.hostPlatform = system; }
  ]

  # Core system modules
  ++ [ ../modules/core ]

  # Host-specific hardware + config
  ++ [ ../hosts/${hostname} ]

  # Role profiles (laptop / desktop / server / …)
  ++ map (p: ../profiles/${p}) profiles

  # NixOwOs module :3
  ++ [ inputs.nixowos.nixosModules.default ]

  # Home Manager module
  ++ [ home-manager.nixosModules.home-manager ]

  # Wire in each user's Home Manager config
  ++ [
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = { inherit inputs; };
        backupFileExtension = "backup";
        users = builtins.listToAttrs (
          map (u: {
            name = u;
            value = import ../users/${u}/home.nix;
          }) users
        );
      };
    }
  ]

  # 6. Declare the user accounts themselves
  ++ map (u: ../users/${u}/system.nix) users

  # 7. Any one-off extras passed at the call site
  ++ extraModules;
}
