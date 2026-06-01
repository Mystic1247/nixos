# modules/features/dev.nix
#
# System-level support for per-project Nix dev shells.
# The actual per-project flake.nix files live in each project repo —
# this module just makes sure the system is ready to host them.

{ pkgs, ... }:

{
  # Allow binaries built outside nixpkgs (e.g. pre-compiled SDKs
  # pulled in by some dev shells) to run on NixOS.
  # NixOS uses a non-standard dynamic linker path, so foreign ELF
  # binaries fail with "No such file or directory" without this.
  programs.nix-ld = {
    enable = true;
    # Common libraries that pre-compiled binaries tend to need.
    # Add more here if a specific tool complains about missing .so files.
    libraries = with pkgs; [
      stdenv.cc.cc.lib   # libstdc++
      zlib
      openssl
      libGL
      vulkan-loader
      xorg.libX11
      xorg.libXcursor
      xorg.libXrandr
      xorg.libXi
      wayland
    ];
  };
}
