{ pkgs, ... }: {
  programs.ghostty = {
    enable = true;

    settings = {
      theme = "Adawaita Dark";
      font-family = "Maple Mono";
  };
}