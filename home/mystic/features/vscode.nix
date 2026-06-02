{ pkgs, ... }: {
  programs.vscode = {
    enable = true;
    
    package = pkgs.vscode; 

    extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      catppuccin.catppuccin-vsc
      jnoortheen.nix-ide
      pkief.material-icon-theme
    ];

    userSettings = {
      "workbench.iconTheme" = "material-icon-theme";
      "workbench.colorTheme" = "Catppuccin Mocha";
      "files.autoSave" = "afterDelay";
      "editor.fontFamily" = "'Maple Mono NF', monospace";
      "editor.fontLigatures" = true;
      "workbench.settings.applyToAllProfiles" = [ ];

      "editor.tabSize" = 2;
      "files.insertFinalNewline" = true;
      "files.trimTrailingWhitespace" = true;
      "workbench.startupEditor" = "none";

      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nixd";
    };

    keybindings = [
      # { key = "ctrl+shift+t"; command = "workbench.action.terminal.toggleTerminal"; }
    ];
  };
}