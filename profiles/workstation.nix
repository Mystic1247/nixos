# profiles/workstation.nix
#
# Everything a graphical machine needs, whatever its form factor.
# Not used on its own: laptop.nix and desktop.nix build on it.
# Each name below is a file in modules/features/.

{ ... }:

let
  feature = name: ../modules/features/${name}.nix;
in
{
  imports = map feature [
    "audio"
    "bluetooth"
    "dev"
    "drawing-tablet"
    "flatpak"
    "fonts"
    "gnome"
    "niri"
    "printing"
    "quiet-boot"
    "virt"
  ];
}
