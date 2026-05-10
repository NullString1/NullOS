{ lib, vars, ... }:
let
  isKDE = vars.desktopEnvironment == "kde";
in
{
  qt = {
    enable = true;
    platformTheme.name = lib.mkForce (if isKDE then "kde" else "kvantum");
    style.name = lib.mkForce "kvantum";
  };
}
