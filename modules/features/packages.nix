{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    bash
    zsh
    git
    wget
    curl
    nh

    btop
    unzip
    zip

    maple-mono.NF
    pantum-driver
  ];
}
