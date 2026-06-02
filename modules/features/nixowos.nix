{ inputs, ... }:

{
  imports = [ inputs.nixowos.homeModules.default ];

  nixowos = {
    enable = true;
    nixos.nixpkgs.enable = false; # 3:
  };
}
