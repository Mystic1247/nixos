{
  description = "Mystic's NixOS fleet: t480, spectre and nasher (Dell Chromebook)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # --- Flake packages, wired in through overlays/default.nix ---
    helium = {
      url = "github:schembriaiden/helium-browser-nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    freesmlauncher = {
      url = "github:FreesmTeam/FreesmLauncher";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-fdm = {
      url = "github:kreutzi/nix-FDM";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sonora = {
      url = "github:sonorahq/sonora";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    # ── Opt-in extras ────────────────────────────────────────────────────────
    # Only hosts that import modules/features/nixowos.nix are affected.
    nixowos = {
      url = "github:yunfachi/nixowos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Currently unused: reserved for the Home Manager niri config
    # (users/mystic/home/desktop/niri.nix). The NixOS side uses nixpkgs' own
    # programs.niri module.
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      mkHost = import ./lib/mkHost.nix { inherit inputs; };
    in
    {
      # The attribute name is the hostname: `nh os switch` / `nixos-rebuild`
      # pick the configuration whose name matches the machine they run on.
      # Each name must have a matching folder under hosts/.
      nixosConfigurations = {
        t480 = mkHost {
          hostname = "t480";
          profiles = [ "laptop" ];
          users = [ "mystic" ];
        };

        spectre = mkHost {
          hostname = "spectre";
          profiles = [ "laptop" ];
          users = [ "mystic" ];
        };

        nasher = mkHost {
          hostname = "nasher";
          profiles = [ "laptop" ];
          users = [ "mystic" ];
        };
      };

      # `nix fmt` formats every .nix file in the repo.
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;
    };
}
