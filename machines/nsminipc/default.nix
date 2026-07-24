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
          networking.firewall = {
            allowedTCPPorts = [
              5540
              5541
              8482
              5353
            ];
            allowedUDPPorts = [
              5540
              5541
              8482
              5353
            ];
          };
          boot.kernel.sysctl = {
            "net.ipv6.conf.enp1s0.accept_ra" = 2; # For HA matterhub
            "net.ipv6.conf.wlp2s0.accept_ra" = 2; # For HA matterhub
            "net.ipv6.conf.enp1s0.accept_ra_rt_info_max_plen" = 64; # For HA matterhub
            "net.ipv6.conf.wlp2s0.accept_ra_rt_info_max_plen" = 64; # For HA matterhub
          };
          services.radvd = {
            enable = true;
            config = ''
              interface enp1s0 {
                AdvSendAdvert on;
                MinRtrAdvInterval 3;
                MaxRtrAdvInterval 10;
                
                prefix fd00:dead:beef::/64 {
                  AdvOnLink on;
                  AdvAutonomous on;
                  AdvRouterAddr off;
                };
              };
            '';
          };
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
