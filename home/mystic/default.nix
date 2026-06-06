# home/mystic/default.nix

{ ... }:

{
  imports = [
    ./core
    ./features
    ./features/niri
  ];
}
