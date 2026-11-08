# fish shell (replaces zsh + oh-my-zsh).
#
# fish already does what the zsh plugins were added for: autosuggestions,
# syntax highlighting, completions and `Alt+S` (prepend sudo) are built in.
# What is added here: the aliases, git shortcuts, an `extract` helper and the
# two key bindings from the old zsh setup.

{ pkgs, ... }:

{
  programs.fish = {
    enable = true;

    # Replace a command with a different default: real aliases.
    shellAliases = {
      ls = "eza --icons --group-directories-first";
      ll = "eza --icons --group-directories-first -l";
      la = "eza --icons --group-directories-first -la";
      tree = "eza --tree --icons";
      cat = "bat";
    };

    # Shortcuts: abbreviations expand into the full command as you type, so you
    # see (and can edit) what will actually run, and your history stays readable.
    shellAbbrs = {
      # Nix. The flake path comes from NH_FLAKE (programs.nh.flake in
      # users/mystic/system.nix), and nh picks this machine's configuration by hostname.
      nix-switch = "nh os switch";
      nix-test = "nh os test";
      nix-clean = "nh clean all --keep 3";
      conf = "cd ~/nixos";
      hconf = "hx ~/nixos";

      # git (plugin-git below adds the oh-my-zsh style set: gst, gco, gp, ...)
      g = "git";
      gs = "git st";
      gl = "git lg";
    };

    plugins = [
      {
        # Port of oh-my-zsh's git plugin: the usual g* abbreviations.
        name = "plugin-git";
        src = pkgs.fishPlugins.plugin-git.src;
      }
    ];

    functions.extract = {
      description = "Extract any common archive: extract <file>...";
      body = ''
        for file in $argv
            if not test -f "$file"
                echo "extract: '$file' is not a file" >&2
                continue
            end

            switch (string lower -- "$file")
                case "*.tar.gz" "*.tgz"
                    tar xzf "$file"
                case "*.tar.bz2" "*.tbz2"
                    tar xjf "$file"
                case "*.tar.xz" "*.txz"
                    tar xJf "$file"
                case "*.tar.zst"
                    tar --zstd -xf "$file"
                case "*.tar"
                    tar xf "$file"
                case "*.zip"
                    unzip "$file"
                case "*.gz"
                    gunzip "$file"
                case "*.bz2"
                    bunzip2 "$file"
                case "*.xz"
                    unxz "$file"
                case "*.zst"
                    unzstd "$file"
                case "*.7z"
                    7z x "$file"
                case "*"
                    echo "extract: don't know how to extract '$file'" >&2
            end
        end
      '';
    };

    interactiveShellInit = ''
      set -g fish_greeting # no welcome message
      set -g fish_color_command green # commands, builtins, functions and aliases

      bind ctrl-space accept-autosuggestion
      bind ctrl-f fzf-file-widget
    '';
  };
}
