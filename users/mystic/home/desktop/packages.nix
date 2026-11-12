# Desktop applications for this user, grouped by purpose.
# CLI tools live in ../shell/tools.nix; system-wide tools in modules/core/packages.nix.

{ pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    # Terminal tools
    cool-retro-term
    fastfetch
    hyfetch

    # Editors
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
    vlc
    inputs.sonora.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Browsers and chat
    helium
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    vesktop
    discord

    # Games
    freesmlauncher

    # Creative
    krita

    # GNOME tweaking and Windows apps
    gnome-extension-manager
    gnome-tweaks
    refine
    winboat

    freedownloadmanager
  ];
}
