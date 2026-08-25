{ pkgs, vars, ... }:
{
  services.kdeconnect = {
    enable = vars.enableKDEConnect;
    indicator = true;
    package = pkgs.kdePackages.kdeconnect-kde;
  };
}