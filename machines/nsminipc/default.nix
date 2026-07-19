{
  self,
  pkgs,
  ...
}:

{
  profile = "server";
  hostname = "nsminipc";

  desktopEnvironment = null;

  stylixImage = self + /wallpapers/screen.jpg;
  waybarConfig = self + /home/waybar/default.nix;
  animationSet = self + /home/hyprland/animations-end4.nix;

  requirePasswordForSudo = false;
  autoUpgrade = false;
  enableAudio = false;
  enableBluetooth = true;

  useNvidia = false;

  enableResticBackup = false;
  enableMinecraft = false;
  enableNVIM = false;
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
  systemd.services.periodic-reboot = {
    description = "Periodic Reboot";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/reboot";
    };
  };

  systemd.timers.periodic-reboot = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "Sun *-*-* 00:00:00";
      Unit = "periodic-reboot.service";
    };
  };
  extraNixosConfig = {
    imports = [
      (
        { config, ... }:
        {
          environment.pathsToLink = [
            "/share/applications"
            "/share/xdg-desktop-portal"
          ];
          sops.secrets.nextdnsIpUpdateUrl = { };
          systemd.services.nextdnsip = {
            description = "NextDNS IP Update Service";
            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.curl}/bin/curl -s $(cat ${config.sops.secrets.nextdnsIpUpdateUrl.path})'";
            };
          };
          systemd.timers.nextdnsip = {
            wantedBy = [ "timers.target" ];
            timerConfig = {
              OnCalendar = "*-*-* 00:00:00"; # Run daily at midnight
              Unit = "nextdnsip.service";
            };
          };
          services.ananicy.settings = {
            apply_cgroup = false;
          };
          services.journald.extraConfig = ''
            SystemMaxUse=50M
            MaxRetentionSec=1month
            CommitIntervalSec=10
          '';
          virtualisation.docker.daemon.settings = {
            "max-concurrent-downloads" = 1;
            "max-concurrent-uploads" = 1;
            "log-driver" = "json-file";
            "log-opts" = {
              "max-size" = "10m";
              "max-file" = "3";
            };
          };
        }
      )
    ];
  };
}
