# Shell prompt (Starship works in every shell, fish included).

{ ... }:

{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      line_break.disabled = true;
      nix_shell = {
        symbol = "❄️ ";
        format = "via [$symbol$state]($style) ";
      };
      git_branch.symbol = " ";
      directory.truncation_length = 4;
    };
  };
}
