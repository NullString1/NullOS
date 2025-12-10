{ ... }:
{
  imports = [
    ./backup.nix
    ./services.nix
    ./virtualisation.nix
    ./vpn.nix
    ./xserver.nix
  ];
}
