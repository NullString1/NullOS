{ lib, ... }:
{
  qt = {
    enable = true;
    platformTheme.name = lib.mkForce "kvantum";
  };
}
