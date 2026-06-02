{ pkgs, ... }: {
  programs.ghostty = {
    enable = true;

    settings = {
      theme = "Maple Mono";
      font-family = "JetBrainsMono Nerd Font";
      font-size = 11;
    };
  };
}