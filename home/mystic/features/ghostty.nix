{ pkgs, ... }: {
  programs.ghostty = {
    enable = true;

    settings = {
      theme = "Adwaita Dark";
      font-family = "JetBrainsMono Nerd Font";
      font-size = 11;
    };
  };
}