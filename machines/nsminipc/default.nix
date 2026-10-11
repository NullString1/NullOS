{
  self,
  pkgs,
  ...
}:

{
  profile = "server";
  hostname = "nsminipc";

  stylixImage = self + /wallpapers/screen.jpg;

  requirePasswordForSudo = false;
  autoUpgrade = false;
  enableAudio = false;
  enableBluetooth = true;
  enableIPForwarding = true;

  extraNixosConfig = {
    imports = [
      (
        { config, ... }:
        {
          networking.firewall = {
            allowedTCPPorts = [
              5540 # for rtsp
              5541 # for rtsp
              8482 # for home assistant matterhub
              67 # for dhcp
              68 # for dhcp
              8123 # for home assistant
              8080 # for evolution_api
            ];
            allowedUDPPorts = [
              5540 # for rtsp
              5541 # for rtsp
              8482 # for home assistant matterhub
              67 # for dhcp
              68 # for dhcp
              8123 # for home assistant
            ];
          };
          boot = {
            devSize = "32m";
            devShmSize = "256m";
            kernel.sysctl = {
              "net.ipv6.conf.enp1s0.accept_ra" = 2; # For HA matterhub
              "net.ipv6.conf.wlp2s0.accept_ra" = 2; # For HA matterhub
              "net.ipv6.conf.enp1s0.accept_ra_rt_info_max_plen" = 64; # For HA matterhub
              "net.ipv6.conf.wlp2s0.accept_ra_rt_info_max_plen" = 64; # For HA matterhub
            };
          };
          services = {
            radvd = {
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
            cloudflared.enable = true;
            journald.settings.Journal = {
              Storage = "volatile";
              RuntimeMaxUse = "32M";
            };
            ananicy.settings = {
              apply_cgroup = false;
            };
          };
          sops.secrets.nextdnsIpUpdateUrl = { };
          systemd = {
            services = {
              nextdnsip = {
                description = "NextDNS IP Update Service";
                serviceConfig = {
                  Type = "oneshot";
                  ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.curl}/bin/curl -s \"$(cat ${config.sops.secrets.nextdnsIpUpdateUrl.path})\"'";
                };
              };
              periodic-reboot = {
                description = "Periodic Reboot";
                serviceConfig = {
                  Type = "oneshot";
                  ExecStart = "${pkgs.systemd}/bin/reboot";
                };
              };
            };
            timers = {
              nextdnsip = {
                wantedBy = [ "timers.target" ];
                timerConfig = {
                  OnCalendar = "*-*-* 00:00:00"; # Run daily at midnight
                  Unit = "nextdnsip.service";
                };
              };
              periodic-reboot = {
                wantedBy = [ "timers.target" ];
                timerConfig = {
                  OnCalendar = "Sun *-*-* 00:00:00";
                  Unit = "periodic-reboot.service";
                };
              };
            };
          };
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
