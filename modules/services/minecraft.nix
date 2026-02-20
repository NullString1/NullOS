{ pkgs, ... }:
{
  services.minecraft-server = {
    enable = true;
    eula = true;
    openFirewall = true;
    package = pkgs.papermc;
  };
}
