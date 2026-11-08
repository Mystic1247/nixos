# Graphics tablets (Wacom, Huion, ...) via OpenTabletDriver.
# Not to be confused with convertible/tablet-mode laptops (see gnome.nix).

{ ... }:

{
  hardware.opentabletdriver.enable = true;

  # Also loads the uinput kernel module, which OpenTabletDriver needs.
  hardware.uinput.enable = true;
}
