# profiles/desktop.nix
#
# A workstation that is always on mains power. (No host uses this yet.)

{ ... }:

{
  imports = [ ./workstation.nix ];

  powerManagement.cpuFreqGovernor = "performance";
}
