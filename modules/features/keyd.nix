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
}
