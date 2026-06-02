{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;

    settings = {
      theme = "Adwaita Dark";
      font-family = "Maple Mono NF";
    };
  };
}
