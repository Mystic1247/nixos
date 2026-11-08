# Small CLI toolbox for every machine, including servers.
# Desktop applications belong in the user's Home Manager config
# (users/<name>/home/desktop/packages.nix), not here.

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    unzip
    zip
    tree
    btop
    gnupg
  ];
}
