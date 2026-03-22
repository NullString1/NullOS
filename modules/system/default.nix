{ vars, lib, ... }:
{
  imports = [
    ./security.nix
    ./nvidia.nix
    ./boot.nix
    ./system.nix
    ./network.nix
    ./printing.nix
    ./hardware_add.nix
    ./audio.nix
  ]
  ++ lib.optionals (vars.laptopPowerManagement) [ ./power.nix ];
}
