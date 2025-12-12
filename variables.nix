{ nixpkgs, ... }:
let
  pkgs = import nixpkgs { system = "x86_64-linux"; };
in
{
  username = "exampleuser";
  hostname = "examplehost";
  system = "x86_64-linux";

  gitUsername = "Example User";
  gitEmail = "email@example.com";

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

  resticRepository = "sftp:user@serverip:/mdata/nsdata";

  extraMonitorSettings = "
    monitor = eDP-1, 1920x1080@60,auto,1
    ";

  printEnable = true;
  printDrivers = [ pkgs.postscript-lexmark ];

  add_rtl8852cu = true;
}
