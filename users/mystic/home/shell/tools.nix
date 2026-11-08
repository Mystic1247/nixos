# Command-line tools. Each is hooked into fish automatically by Home Manager.

{ ... }:

{
  # Fuzzy finder: Ctrl+R history, Ctrl+F (bound in fish.nix) files, Alt+C directories.
  programs.fzf = {
    enable = true;
    defaultOptions = [
      "--height 40%"
      "--border"
      "--preview-window=right:50%"
    ];
    fileWidget.options = [ "--preview 'bat --style=numbers --color=always --line-range=:200 {}'" ];
    changeDirWidget.options = [ "--preview 'eza --tree --level=2 --icons --color=always {}'" ];
  };

  programs.eza.enable = true; # ls replacement (aliased in fish.nix)

  programs.bat = {
    enable = true; # cat replacement (aliased in fish.nix)
    config.theme = "TwoDark";
  };

  programs.zoxide.enable = true; # smarter cd: `z <partial-name>`

  # Per-directory environments; nix-direnv makes `use flake` fast and cached.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
