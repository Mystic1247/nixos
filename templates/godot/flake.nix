# templates/godot/flake.nix
#
# Drop this flake.nix into the root of any Godot project.
# Then run:  echo "use flake" > .envrc && direnv allow
# After that, `cd`-ing into the folder auto-activates the dev shell.
#
# What you get:
#   - godot4 binary in PATH
#   - Godot export templates (for building release binaries)
#   - gdtoolkit (GDScript formatter + linter)
#   - butler (itch.io publishing tool)
#   - imagemagick (texture/icon pipeline)

{
  description = "Godot 4 game dev shell";

  inputs = {
    nixpkgs.url     = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
      in {
        devShells.default = pkgs.mkShell {
          name = "godot-dev";

          packages = with pkgs; [
            # Core
            godot_4                  # The editor + runtime
            godot_4-export-templates # Pre-built export templates

            # GDScript tooling
            gdtoolkit_4              # gdformat (formatter) + gdlint (linter)

            # Asset pipeline
            imagemagick              # Convert/resize textures, generate icons
            ffmpeg                   # Audio/video processing
            optipng                  # Compress PNG assets
            
            # Publishing
            butler                   # itch.io uploader

            # Useful extras
            git
            just                     # Command runner (like make, but nicer)
          ];

          # Environment variables available inside the shell
          shellHook = ''
            echo "🎮 Godot dev shell — $(godot4 --version 2>/dev/null || echo 'ready')"
            echo "   gdformat, gdlint, butler, imagemagick all available."
          '';
        };
      });
}
