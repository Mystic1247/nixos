{
  description = "...";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helium = {
      url = "github:schembriaiden/helium-browser-nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixowos = {
      url = "github:yunfachi/nixowos";
      inputs.nixpkgs.follows = "nixpkgs"; # ???
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      myLib = import ./lib { inherit nixpkgs home-manager inputs; };
      inherit (myLib) mkHost;
    in
    {

      nixosConfigurations = {
        spectre = mkHost {
          hostname = "spectre";
          system = "x86_64-linux";
          profiles = [ "laptop" ];
          users = [ "mystic" ];
        };

        chromebook = mkHost {
          hostname = "chromebook";
          system = "x86_64-linux";
          profiles = [ "laptop" ];
          users = [ "mystic" ];
        };
      };

      templates = {
        godot = {
          path = ./templates/godot;
          description = "Godot 4 game dev shell — editor, export templates, gdtoolkit, butler";
        };
        gtk = {
          path = ./templates/gtk;
          description = "GTK4 app dev shell — Vala/Python/Rust variants with libadwaita";
        };
      };
    };
}
