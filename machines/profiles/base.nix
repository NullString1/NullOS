{ pkgs, ... }:

{
  system = "x86_64-linux";
  username = "nullstring1";

  gitUsername = "NullString1";
  gitEmail = "kernd2005@gmail.com";

  keyboardLayout = "gb";
  consoleKeyMap = "uk";

  timeZone = "Europe/London";
  locale = "en_GB.UTF-8";

  terminal = "ghostty";
  browser = pkgs.brave;

  printEnable = false;
  printDrivers = [ ];

  useNvidia = false;
  useNvidiaPrime = false;
  intelBusId = "PCI:0:2:0";
  nvidiaBusId = "PCI:1:0:0";

  enableDocker = false;
  enableVSCode = false;
  enableOpencode = false;
  enableAndroid = false;
  enableNVIM = false;
  enableDirenv = false;
  enableDBGate = false;
  enableDevMisc = false;
  enableOllama = false;
  enableExposeOllama = false;
  enableGit = false;
  enableWine = false;

  enableSteam = false;
  enableLutris = false;
  enableBottles = false;
  enableMoonlight = false;
  enableMinecraft = false;

  enableTailscale = false;
  enableMullvadVPN = false;
  enableCloudflareWarp = false;
  enableOpenFortiVPN = false;

  enableFusion360 = false;
  enableLibreOffice = false;
  enableFlatpak = false;
  enableQBittorrent = false;
  enableGnomeNetworkDisplays = false;

  enableResticBackup = false;
}
