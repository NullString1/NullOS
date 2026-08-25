{
  self,
  lib,
  pkgs,
  ...
}:

{
  profile = "pc";
  hostname = "nspc";

  useNvidia = true;

  stylixImage = self + /wallpapers/screen.jpg;
  waybarConfig = self + /home/waybar/default.nix;
  animationSet = self + /home/hyprland/animations-end4.nix;

  enableResticBackup = false;
  enableLlamaCpp = false;
  enableExposeLlamaCpp = false;

  requirePasswordForSudo = false;

  enableAndroid = false;
  enableSteam = true;
  enableBluetooth = false;
  enableLutris = false;
  enableRare = true;
  enableBottles = false;
  enableMoonlight = false;
  enableWine = false;
  enableCloudflareWarp = false;
  enableOpenFortiVPN = false;
  enableLibreOffice = false;
  enableQBittorrent = false;
  enableGnomeNetworkDisplays = false;

  extraNixosConfig = {
    imports = [
      (
        { ... }:
        {
          nix.settings = {
            system-features = [ "gccarch-x86-64-v3" ];
          };
          hardware.nvidia = {
            open = lib.mkForce true;
          };
          environment.etc."xdg/weston/weston.ini".text = ''
            [output]
            name=DP-3
            mode=preferred
            position=0,0

            [output]
            name=HDMI-A-1
            mode=preferred
            position=1920,0
          '';
          environment.systemPackages = [
            pkgs.mangohud
            pkgs.legendary-gl
          ];
        }
      )
    ];
  };
}
