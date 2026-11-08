{ ... }:

{
  # Already NixOS's default; spelled out because it is security-relevant and
  # should not silently change if the default ever does.
  security.sudo.wheelNeedsPassword = true;
}
