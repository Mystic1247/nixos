{ pkgs, config, ... }:

{
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";

    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
        "docker"
        "extract"
      ];
    };

    shellAliases = {
      # nix thingies
      nix-switch = "nh os switch ~/nixos/";
      nix-test = "nh os test ~/nixos/";
      nix-clean = "nh clean all --keep 3";
      conf = "cd ~/nixos";
      hconf = "hx ~/nixos";

      # general
      ls = "eza --icons --group-directories-first";
      ll = "eza --icons --group-directories-first -l";
      la = "eza --icons --group-directories-first -la";
      tree = "eza --tree --icons";
      cat = "bat";
      # z          = "cd";

      # git
      g = "git";
      gs = "git st";
      gl = "git lg";
    };

    initExtra = ''
      ZSH_HIGHLIGHT_STYLES[command]='fg=green'
      ZSH_HIGHLIGHT_STYLES[alias]='fg=green'
      ZSH_HIGHLIGHT_STYLES[builtin]='fg=green'
      ZSH_HIGHLIGHT_STYLES[function]='fg=green'

      bindkey '^ ' autosuggest-accept
      bindkey '^f' fzf-file-widget
    '';
  };

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

  # Shell utils
  programs.fzf = {
    enable = true;
    defaultOptions = [
      "--height 40%"
      "--border"
      "--preview-window=right:50%"
    ];
  };
  programs.eza.enable = true;
  programs.bat = {
    enable = true;
    config.theme = "TwoDark";
  };
  programs.zoxide.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
