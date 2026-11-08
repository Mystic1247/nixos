# Bootloader and kernel. Cosmetic boot settings live in features/quiet-boot.nix.

{ lib, pkgs, ... }:

{
  boot.loader.limine = {
    enable = true;
    maxGenerations = 10;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # Newest kernel for fresh laptop hardware. mkDefault so a profile or host
  # (e.g. a server) can pin an LTS kernel with a plain assignment.
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
}
