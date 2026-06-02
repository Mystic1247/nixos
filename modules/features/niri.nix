{ pkgs, ... }:

{
  programs.niri.enable = true; # registers niri as a GDM session + installs it

  # Niri needs these portals for screen sharing, file pickers, etc.
  # GNOME already brings xdg-desktop-portal-gnome, but niri needs gtk as fallback
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    configPackages = [ pkgs.niri ];
  };

  # Polkit agent (GNOME has its own, but niri doesn't — needed for sudo GUI prompts)
  security.polkit.enable = true;
}
