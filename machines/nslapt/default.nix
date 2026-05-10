{ self, ... }:

{
  profile = "pc";
  hostname = "nslapt";

  useNvidia = true;
  useNvidiaPrime = true;
  enableNvidiaOffload = true;
  
  intelBusId = "PCI:0:2:0";
  nvidiaBusId = "PCI:2:0:0";

  extraMonitorSettings = ''
    monitor = eDP-1, 1920x1080@60,auto,1
  '';

  waybarConfig = self + /home/waybar/default.nix;
  stylixImage = self + /wallpapers/screen.jpg;

  enableNVIM = false;

  enableResticBackup = true;
  enableWinboat = true;

  requirePasswordForSudo = false;

  laptopPowerManagement = true;

  services = {
    asusd.enable = true;
    usbmuxd.enable = true;
  };

  nix.settings = {
    substituters = [
      "https://logsmart-cache.cachix.org"
    ];
    trusted-public-keys = [
      "logsmart-cache.cachix.org-1:nhxeVYtlgc5IZ+6zALnIT/6PdZQHpjPwV+R0qwjm+BQ="
    ];
    system-features = [ "gccarch-x86-64-v3" "gccarch-tigerlake" ];
  };
}
