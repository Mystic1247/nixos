# overlays/default.nix
#
# Overlays applied to the system's nixpkgs (see modules/core/nix.nix).
# Because Home Manager runs with useGlobalPkgs, they apply to user packages too.

{ inputs }:

[
  inputs.helium.overlays.default # pkgs.helium
  inputs.freesmlauncher.overlays.default # pkgs.freesmlauncher
  (_final: prev: {
    freedownloadmanager =
      inputs.nix-fdm.packages.${prev.stdenv.hostPlatform.system}.default.overrideAttrs
        (old: {
          src = old.src.overrideAttrs {
            outputHash = "sha256-XLFyp12RtIuDC1JO/sojFXk0WJX833bVesaocwi9CDI=";
          };
        });
  })
]
