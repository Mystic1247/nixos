# NixOwOS (https://github.com/yunfachi/nixowos): branding, os-release and logo
# overlays. Opt-in per host: add this file to the host's `imports`.
#
# Why it isn't applied everywhere: the NixOwOS module adds its package
# overlays (including a patched fastfetch that has to be compiled locally)
# as soon as it is imported, regardless of `nixowos.enable`. Importing it only
# where it is wanted keeps the other machines on plain, cached packages.

{ inputs, ... }:

{
  imports = [ inputs.nixowos.nixosModules.default ];

  nixowos.enable = true;
}
