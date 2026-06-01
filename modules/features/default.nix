{ lib, ... }:

{
  imports = 
    let
      files = builtins.readDir ./.;
      validFiles = lib.filterAttrs 
        (name: type: 
          (type == "regular" || type == "symlink") && 
          (lib.hasSuffix ".nix" name) && 
          (name != "default.nix")
        ) files;
    in
    lib.mapAttrsToList (name: type: ./. + "/${name}") validFiles;
}