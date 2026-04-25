{ self, ... }:

{
  profile = "pc";
  hostname = "nspc";

  useNvidia = true;

  stylixImage = self + /wallpapers/screen.jpg;
  waybarConfig = self + /home/waybar/default.nix;
  animationSet = self + /home/hyprland/animations-end4.nix;

  enableResticBackup = false;
  enableOllama = false;
  enableExposeOllama = false;

  requirePasswordForSudo = false;

  enableAndroid = false;
  enableDBGate = false;
  enableSteam = false;
  enableLutris = false;
  enableBottles = false;
  enableMoonlight = false;
  enableWine = false;
  enableCloudflareWarp = false;
  enableOpenFortiVPN = false;
  enableLibreOffice = false;
  enableQBittorrent = false;
  enableGnomeNetworkDisplays = false;

  hardware.nvidia = {
    open = true;
  };
}
