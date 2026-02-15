{ ... }:
{
  imports = [
    ./power.nix
    ./security.nix
    ./nvidia.nix
    ./boot.nix
    ./system.nix
    ./network.nix
    ./printing.nix
    ./hardware_add.nix
    ./audio.nix
    #./rtl8852cu.nix
  ];
}
