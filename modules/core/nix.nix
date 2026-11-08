# Nix itself: nixpkgs settings, caches, store maintenance.

{ inputs, ... }:

{
  nixpkgs = {
    config.allowUnfree = true;
    overlays = import ../../overlays { inherit inputs; };
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    warn-dirty = false;

    # Added to NixOS's built-in defaults, which already include
    # cache.nixos.org and its signing key. Don't repeat those here.
    substituters = [ "https://nix-community.cachix.org" ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCUSeBo="
    ];
  };

  nix.optimise.automatic = true;

  # nh is the day-to-day CLI (see the shell abbreviations in the user's fish
  # config). Its weekly clean-up replaces nix.gc; the two are mutually exclusive.
  # The flake path that `nh os switch` uses is set per user (users/<name>/system.nix).
  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep-since 14d --keep 3";
    };
  };
}
