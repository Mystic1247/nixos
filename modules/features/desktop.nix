{ pkgs, ... }:

{
  services.xserver.enable = true;

  services.displayManager.gdm.enable = true;
  
  services.desktopManager.gnome.enable = true;

  services.gnome.core-shell.enable = true;

  services.udev.packages = with pkgs; [ gnome-settings-daemon ];

  services.flatpak.enable = true;

  services.libinput.enable = true;

  hardware.sensor.iio.enable = true;

  # GNOME extensions
  environment.systemPackages = with pkgs; [
    gnomeExtensions.transparent-top-bar-adjustable-transparency
    gnomeExtensions.advanced-alttab-window-switcher
    gnomeExtensions.compiz-windows-effect
    gnomeExtensions.touchpad-switcher
    gnomeExtensions.applications-menu
    gnomeExtensions.burn-my-windows
    gnomeExtensions.screen-rotate
    gnomeExtensions.blur-my-shell
    gnomeExtensions.dash-to-panel
    gnomeExtensions.dash-to-dock
    gnomeExtensions.appindicator  
    gnomeExtensions.caffeine
    gnomeExtensions.gjs-osk
    gnomeExtensions.touchup
    gnomeExtensions.arcmenu
  ];

  # stupid gnome apps
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    epiphany
    geary
  ];
}
