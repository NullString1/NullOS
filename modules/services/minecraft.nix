{ pkgs, ... }:
{
  services.minecraft = {
    enable = true;
    eula = true;
    openFirewall = true;
    package = pkgs.papermc;
  };
} 