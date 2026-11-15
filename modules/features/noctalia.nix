# Noctalia: the desktop shell (bar, launcher, notifications, lock screen, ...)
# that pairs with Umbriel. It is installed system-wide here but only started by
# Umbriel's own `general.autostart` (users/<name>/home/desktop/umbriel.toml).
# Do NOT enable programs.noctalia.systemd here: that user service is tied to
# graphical-session.target and would also start Noctalia inside GNOME and niri.

{ inputs, ... }:

{
  # Must be the flake's module: it replaces nixpkgs' own programs.noctalia module.
  imports = [ inputs.noctalia.nixosModules.default ];

  programs.noctalia = {
    enable = true;

    # NetworkManager, Bluetooth, UPower and power-profiles-daemon for Noctalia's
    # Wi-Fi, Bluetooth, battery and power-mode widgets. All set with mkDefault,
    # so core/networking.nix, bluetooth.nix and power.nix still win.
    recommendedServices.enable = true;
  };
}
