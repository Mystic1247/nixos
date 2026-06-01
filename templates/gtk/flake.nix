# templates/gtk/flake.nix
#
# Drop this flake.nix into the root of any GTK application project.
# Supports multiple language options — uncomment the section you need.
#
# Then run:  echo "use flake" > .envrc && direnv allow

{
  description = "GTK application dev shell";

  inputs = {
    nixpkgs.url     = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # ------------------------------------------------------------------ #
        # Choose your GTK toolkit version
        # ------------------------------------------------------------------ #
        gtkVersion = pkgs.gtk4;   # or pkgs.gtk3

        # ------------------------------------------------------------------ #
        # Common GTK dependencies (all languages need these)
        # ------------------------------------------------------------------ #
        gtkDeps = with pkgs; [
          gtkVersion
          glib
          gobject-introspection   # GObject type introspection (needed by most bindings)
          pkg-config              # Finds library flags at build time
          desktop-file-utils      # Validates .desktop files
          glib.dev                # GLib headers
          libadwaita              # GNOME HIG widgets (for modern GNOME apps)
        ];

      in {
        # ------------------------------------------------------------------ #
        # Vala  (compiled, GObject-native, feels like C# — good for GNOME)
        # ------------------------------------------------------------------ #
        devShells.vala = pkgs.mkShell {
          name = "gtk-vala";
          packages = gtkDeps ++ (with pkgs; [
            vala          # Vala compiler
            meson         # Build system (standard for Vala/GNOME projects)
            ninja         # Backend for meson
          ]);
          shellHook = ''
            echo "🦋 GTK/Vala dev shell — vala $(valac --version), GTK4 ready"
          '';
        };

        # ------------------------------------------------------------------ #
        # Python  (fast to iterate, great for tools and utilities)
        # ------------------------------------------------------------------ #
        devShells.python = pkgs.mkShell {
          name = "gtk-python";
          packages = gtkDeps ++ (with pkgs; [
            (python3.withPackages (ps: with ps; [
              pygobject3    # Python GTK/GObject bindings
              pycairo       # Cairo drawing (often needed alongside GTK)
            ]))
            blueprint-compiler  # .blp UI files → XML (modern GTK UI workflow)
          ]);
          shellHook = ''
            echo "🐍 GTK/Python dev shell — $(python3 --version), PyGObject ready"
          '';
        };

        # ------------------------------------------------------------------ #
        # Rust  (safe, fast, growing GTK ecosystem)
        # ------------------------------------------------------------------ #
        devShells.rust = pkgs.mkShell {
          name = "gtk-rust";
          packages = gtkDeps ++ (with pkgs; [
            rustup          # Rust toolchain manager
            cargo           # Package manager + build tool
            rust-analyzer   # LSP server
            clippy          # Linter
          ]);
          # gtk-rs reads library paths from pkg-config at build time
          PKG_CONFIG_PATH = "${pkgs.gtk4.dev}/lib/pkgconfig:${pkgs.libadwaita.dev}/lib/pkgconfig";
          shellHook = ''
            echo "🦀 GTK/Rust dev shell — $(rustc --version 2>/dev/null || echo 'run: rustup install stable'), gtk4-rs ready"
          '';
        };

        # ------------------------------------------------------------------ #
        # Default shell (Vala — change to taste)
        # ------------------------------------------------------------------ #
        devShells.default = pkgs.mkShell {
          name = "gtk-dev";
          packages = gtkDeps ++ (with pkgs; [
            vala meson ninja
            blueprint-compiler
          ]);
          shellHook = ''
            echo "🖼️  GTK dev shell — GTK4 + Vala + Meson ready"
            echo "   Other shells available: nix develop .#python  |  nix develop .#rust"
          '';
        };
      });
}
