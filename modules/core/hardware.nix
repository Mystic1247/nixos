# Hardware support shared by every machine.
# Per-machine hardware (disks, CPU modules) is in hosts/<name>/hardware-configuration.nix.

{ ... }:

{
  # Non-free firmware blobs (Wi-Fi, GPU, CPU microcode updates, ...).
  hardware.enableRedistributableFirmware = true;
}
