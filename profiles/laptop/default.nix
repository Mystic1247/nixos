# profiles/laptop/default.nix

{ ... }:

{
  imports = [
    ../../modules/features/audio.nix
    ../../modules/features/bluetooth.nix
    ../../modules/features/desktop.nix
    ../../modules/features/dev.nix
    ../../modules/features/keyd.nix
    # ../../modules/features/niri.nix
    ../../modules/features/packages.nix
    ../../modules/features/power.nix
    ../../modules/features/printing.nix
    ../../modules/features/tablet.nix
    ../../modules/features/virt.nix
  ];
}
