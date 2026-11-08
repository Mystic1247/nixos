# Containers with Podman (docker-compatible CLI, daemonless, rootless).

{ pkgs, ... }:

{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true; # `docker` command is an alias for podman
    defaultNetwork.settings.dns_enabled = true; # containers on one network can resolve each other
  };

  environment.systemPackages = with pkgs; [
    podman-compose
    podman-tui
  ];
}
