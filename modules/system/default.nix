{ ... }:
{
  imports = [
    ./power.nix
    ./security.nix
    ./nvidia.nix
    ./boot.nix
    ./system.nix
    ./hardware.nix
    ./network.nix
    ./printing.nix
    ./hardware_add.nix
    ./audio.nix
  ];
}
