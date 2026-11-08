# Terminal. Starts the user's login shell (fish) and detects it for shell
# integration automatically. Font installed by modules/features/fonts.nix.

{ ... }:

{
  programs.ghostty = {
    enable = true;

    settings = {
      theme = "Adwaita Dark";
      font-family = "Maple Mono NF";
    };
  };
}
