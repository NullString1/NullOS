{ pkgs, ... }:
{
  # User and System Settings
  username = "exampleuser";
  hostname = "examplehost";
  system = "x86_64-linux";

  keyboardLayout = "gb";
  consoleKeyMap = "uk";

  timeZone = "Europe/London";
  locale = "en_GB.UTF-8";

  # Desktop Environment: "hyprland" or "kde"
  desktopEnvironment = "hyprland";

  stylixImage = wallpapers/screen.jpg;

  # Hyprland-specific settings (only used when desktopEnvironment = "hyprland")
  waybarConfig = home/waybar/default.nix;

  animationSet = home/hyprland/animations-end4.nix;

  extraMonitorSettings = "
    monitor = eDP-1, 1920x1080@60,auto,1
    ";

  # Git Settings (Enable by setting enableGit to true in variables.nix)
  gitUsername = "ExampleUser";
  gitEmail = "exampleuser@example.com";
  access-tokens = "github.com=your_github_token_here";

  # Configurable Default Applications
  terminal = "ghostty";
  browser = pkgs.brave;

  # Backup Settings
  enableResticBackup = false;
  resticRepository = "sftp:exampleuser@examplehost:/path/path";

  # Drivers and Hardware
  printEnable = false;
  printDrivers = [ ];

  useNvidia = true;
  useNvidiaPrime = true;
  intelBusId = "PCI:0:2:0";
  nvidiaBusId = "PCI:2:0:0";

  # Dev Tools
  enableDocker = true;
  enableVSCode = true;
  enableOpencode = false;
  enableAndroid = false;
  enableNVIM = true;
  enableDirenv = true;
  enableDBGate = false;
  enableDevMisc = true; # 7zip, binwalk, hexdump, unrar, unzip, waypipe, cachix, nixfmt, httpie-desktop
  enableOllama = false;
  enableExposeOllama = false;
  enableGit = true; # Git CLI and GitHub CLI
  enableWine = true;

  # Gaming
  enableSteam = false;
  enableLutris = false;
  enableBottles = false;
  enableMoonlight = false;
  enableMinecraft = false;

  # VPN Services
  enableTailscale = true;
  enableMullvadVPN = false;
  enableCloudflareWarp = false;
  enableOpenFortiVPN = false;

  # Misc
  enableFusion360 = false;
  enableLibreOffice = false;
  enableFlatpak = false;
  enableQBittorrent = false;
  enableGnomeNetworkDisplays = false;
}
