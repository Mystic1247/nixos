# Desktop applications for this user, grouped by purpose.
# CLI tools live in ../shell/tools.nix; system-wide tools in modules/core/packages.nix.

{ pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    # Terminal tools
    cool-retro-term
    fastfetch
    hyfetch

    # Editors and notes
    foliate
    helix
    micro
    obsidian
    zed-editor

    # Music and audio
    cava
    cavasik
    nuclear
    parabolic
    localsend
    pear-desktop
    ytmdesktop
    monophony
    rmpc

    # Browsers and chat
    helium
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    vesktop
    discord
    zapfast

    # Games
    freesmlauncher

    # Creative
    krita

    # GNOME tweaking and Windows apps
    gnome-tweaks
    refine
    winboat
  ];
}
