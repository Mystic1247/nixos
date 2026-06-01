{ ... }: 

{
  imports = [
    ./boot.nix
    ./networking.nix
    ./users.nix
    ./nix.nix
  ];
}
