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

    nil
    # alejandra
    nixfmt
    gnupg

    maple-mono.NF
    pantum-driver
  ];
}
