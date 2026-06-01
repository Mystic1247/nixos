{ pkgs, inputs, ... }:

{
  imports = [ inputs.niri.nixosModules.niri ];
  programs.niri.enable = true;
  
  # environment.systemPackages = with pkgs; [
  #   wl-clipboard
  #   wayland-utils
  # ];
}