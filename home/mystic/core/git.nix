{ ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Mystic";
        email = "meow@cat.com";
      };

      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      rerere.enabled = true;
      column.ui = "auto";
      branch.sort = "-committerdate";

      diff.algorithm = "histogram";
      merge.conflictstyle = "zdiff3";

      alias = {
        lg = "log --oneline --graph --decorate --all";
        st = "status -sb";
      };
    };
  };
}
