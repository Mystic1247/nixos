# niri (scrollable-tiling Wayland compositor), installed from nixpkgs and
# registered as a GDM session next to GNOME. Its per-user config belongs in
# users/<name>/home/desktop/niri.nix.

{ pkgs, ... }:

{
  programs.niri.enable = true; # installs niri and registers the GDM session

  # niri needs these portals for screen sharing, file pickers, etc.
  # GNOME brings xdg-desktop-portal-gnome; the gtk portal is the fallback.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    configPackages = [ pkgs.niri ];
  };

  # Polkit is what lets GUI apps ask for admin rights. GNOME ships its own
  # agent, but niri has none: one (e.g. polkit_gnome) must be started from
  # niri's own config, otherwise GUI password prompts won't appear in niri.
  security.polkit.enable = true;
}
