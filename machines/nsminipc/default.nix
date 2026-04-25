{ self, ... }:

{
  profile = "server";
  hostname = "nsminipc";

  desktopEnvironment = "hyprland";

  stylixImage = self + /wallpapers/screen.jpg;
  waybarConfig = self + /home/waybar/default.nix;
  animationSet = self + /home/hyprland/animations-end4.nix;

  requirePasswordForSudo = false;
  enableAudio = false;
  
  useNvidia = false;

  enableResticBackup = false;
  enableMinecraft = false;

  enableVSCode = false;
  enableAndroid = false;
  enableDBGate = false;
  enableDevMisc = false;
  enableOpencode = false;
  enableWine = false;
  enableSteam = false;
  enableLutris = false;
  enableBottles = false;
  enableMoonlight = false;
  enableCloudflareWarp = false;
  enableOpenFortiVPN = false;
  enableLibreOffice = false;
  enableFlatpak = false;
  enableQBittorrent = false;
  enableGnomeNetworkDisplays = false;

  boot = {
    devSize = "32m";
    devShmSize = "256m";
  };
}
