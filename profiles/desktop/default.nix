# profiles/desktop/default.nix

# abandoned for now since i dont own any desktop pcs for now owo

{ ... }:

{
  imports = [
    ../../modules/features/audio.nix
    ../../modules/features/bluetooth.nix
    ../../modules/features/desktop.nix
    ../../modules/features/packages.nix
    ../../modules/features/printing.nix
    ./../modules/features/tablet.nix
    ../../modules/features/virt.nix
  ];

  powerManagement.cpuFreqGovernor = "performance";
}
