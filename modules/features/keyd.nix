# Key remapping daemon (https://github.com/rvaiya/keyd).
#
# This module only turns the daemon on. Each host supplies its own mappings:
#
#   services.keyd.keyboards.default.settings = {
#     main = { capslock = "esc"; };
#   };

{ ... }:

{
  services.keyd.enable = true;

  # The keyd module doesn't create this group itself. users/<name>/system.nix
  # adds the user to it when it exists.
  users.groups.keyd = { };
}
