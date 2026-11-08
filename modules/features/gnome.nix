# GNOME desktop with GDM. niri (niri.nix) is offered as a second session
# in the GDM login screen, so both desktops are installed side by side.

{ pkgs, ... }:

{
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Accelerometer / ambient light support, so GNOME can auto-rotate the screen
  # on convertibles. Harmless on machines without these sensors.
  hardware.sensor.iio.enable = true;

  # GNOME extensions. Installing them only makes them available: switch them
  # on in the Extensions app. Machine-specific ones belong in the host's own
  # systemPackages (see hosts/nasher).
  environment.systemPackages = with pkgs; [
    gnomeExtensions.transparent-top-bar-adjustable-transparency
    gnomeExtensions.advanced-alttab-window-switcher
    gnomeExtensions.compiz-windows-effect
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.applications-menu
    gnomeExtensions.burn-my-windows
    gnomeExtensions.just-perfection
    gnomeExtensions.blur-my-shell
    gnomeExtensions.dash-to-panel
    gnomeExtensions.dash-to-dock
    gnomeExtensions.appindicator
    gnomeExtensions.glocalsend
    gnomeExtensions.gsconnect
    gnomeExtensions.medialine
    gnomeExtensions.caffeine
    gnomeExtensions.hot-edge
    gnomeExtensions.arcmenu
  ];

  # Trim the default GNOME app set.
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    epiphany
    geary
  ];
}
