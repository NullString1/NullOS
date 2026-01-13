{ nixpkgs, ... }:
let
  pkgs = import nixpkgs { system = "x86_64-linux"; };
in
{
  username = "exampleuser";
  hostname = "examplehost";
  system = "x86_64-linux";

  gitUsername = "exampleuser";
  gitEmail = "exampleuser@examplehost";

  terminal = "ghostty";
  browser = pkgs.brave;

  keyboardLayout = "gb";
  consoleKeyMap = "uk";

  timeZone = "Europe/London";
  locale = "en_GB.UTF-8";

  useNvidiaPrime = true;
  intelBusId = "PCI:0:2:0";
  nvidiaBusId = "PCI:2:0:0";

  stylixImage = wallpapers/screen.jpg;
  waybarConfig = home/waybar/default.nix;

  animationSet = home/hyprland/animations-end4.nix;

  resticRepository = "sftp:exampleuser@host:/path/path";

  extraMonitorSettings = "
    monitor = eDP-1, 1920x1080@60,auto,1
    ";

  printEnable = true;
  printDrivers = [ ];

  add_rtl8852cu = false;
}
