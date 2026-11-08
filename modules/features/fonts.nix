# System-wide fonts. Terminal and editor settings in the user's Home Manager
# config refer to "Maple Mono NF" by name.

{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    maple-mono.NF
  ];
}
