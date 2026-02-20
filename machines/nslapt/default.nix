{ self, ... }:

{
  profile = "pc";
  hostname = "nslapt";

  useNvidia = true;
  useNvidiaPrime = true;
  intelBusId = "PCI:0:2:0";
  nvidiaBusId = "PCI:2:0:0";

  extraMonitorSettings = ''
    monitor = eDP-1, 1920x1080@60,auto,1
  '';

  stylixImage = self + /wallpapers/screen.jpg;
  waybarConfig = self + /home/waybar/default.nix;
  animationSet = self + /home/hyprland/animations-end4.nix;

  enableResticBackup = true;
}
