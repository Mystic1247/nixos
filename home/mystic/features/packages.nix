{ pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    cool-retro-term
    ghostty
    helix
    micro

    gnupg
    nixfmt-rfc-style
    nil

    fastfetch
    hyfetch
    cava
    cavalier

    pear-desktop
    prismlauncher
    # freesm
    vesktop
    # dorion
    rmpc
    firefox
    inputs.helium.packages.${system}.default
    obsidian
    parabolic
    foliate
    krita

    gnome-tweaks
    refine

    winboat
    vscode
  ];
}
