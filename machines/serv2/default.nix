{
  pkgs,
  lib,
  ...
}:

let
  authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEzGg0/X4gtDg5+KnmQGK4ciCF4I1K650cPTrSESVL93 nullstring1@nspc"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIq5F5DvaWnWzTes8X5IVaSNMhTWomZONvwFltluvHjS nullstring1@nsminipc"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICIEaLsNfTn0HXtdalK7JhDRd21xDnO05z7yEduXWAHC nullstring1@pi"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII50+qCRNjcrdy/msr1haoqxF37rDI72+vqMQwve907S nullstring1@picam2"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDKKvcuOqpg27zYB+A5QYVGe8I6CCqW5/OyNeQI6y53gvHOtnsxO1Cd8zA7Cvwmd/tzxhTQIRyV09A8Pa53TrEbji0dxmCO0LqP0KVG584yFd0mqEG9qe/WLiQejjfkmvlViwswWDZTnoQs65bpa2oVak48ayd2e6dJ+UAij6zmfRZyO0rkcBnu61krkWLscOVJSe0TlKPRPUeukJjENws2yh0myc9yZrJDWeUD/n4Ym4MAdFR4gguvp/ona/af0DQyOYf8Z5XlimhhNL4WbJl1aHCG2OvC0cQhMh2IcSuSXZbSDEwoT98fMeobt/8QPG6ALfk9R1AzLa51moLqUGLnkpU6zczZ20yt1s7Mgk/yBAna0kdEnkuF48kTZR9AFNlwZkgwS+9azcnkyAwNo5isKNYm4RO9z7JVE5/KGCNBtMAGw0QHTP0sQ+UuvNcdOVTA/WviGui6Ak/ySoDsdqPMtwelTvyTwPvnOueHS7zqxGSt4jhNTyeygUAkNgJ3g6c= bilbo@DanielLPTP"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDKST0osGDJaG81ngm+hNXBKBoUzpzoTlbXArs59W0wL ubuntu@amd"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCvhfkUARoafY1DZeOrmvPMAg0BqO5tpXfnKmvPh0Y/kKBJR5lJCHkmalPNwQBVT/DYsiRlT7BKUjRudJBz1FqeaEYQRBmBFCBy/vz2Qgc/dftKVx/bz6i47WMu1/ZZTcPl0k5b2lT7hz4KtDZoTjJJMxyKwJenOGE5pykosLg2JNUFdLMd98nvY8ECmoYtLa59tIEXisEX/BCMUmOjJFgu7/qzVinaTr3LwlbMk3SremlR6ICmEvKQKVbo1vB8WUZ3gWpJgfLAwDleSFADOaZa86I3KBeXrHK6QD1rAvP7tvTnqXVlEx8AwqniyQir+CXXUKzWtvovsbq1xF8F4nBL id_rsa_auto_generated"
  ];
in
{
  profile = "server";
  hostname = "serv2";

  requirePasswordForSudo = false;
  autoUpgrade = false;

  enableDocker = true;
  enableTailscale = true;
  enableNextDNS = true;

  extraNixosConfig =
    { config, lib, pkgs, ... }:
    {
      # Oracle Cloud Infrastructure ARM64 EFI Bootloader
    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.loader.grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = true;
      device = "nodev";
      extraConfig = ''
        terminal_output console
      '';
    };
    boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
    boot.loader.efi.efiSysMountPoint = "/boot/efi";
    boot.kernelParams = [ "console=ttyAMA0,115200" ];

    # Sudo rules: allow passwordless sudo for admin users
    security.sudo.extraRules = [
      {
        users = [ "nullstring1" ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];

    # Disable smartd on cloud virtual disks (no physical SMART support)
    services.smartd.enable = lib.mkForce false;

    # Enforce standard permissions on /var/log
    systemd.tmpfiles.rules = [
      "d /var/log 0755 root root -"
    ];

    # Networking: OCI uses DHCP on enp0s6
    networking.interfaces.enp0s6.useDHCP = true;
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [
        22    # SSH & SFTP Restic target
        8080  # Comtrak backend
        3900  # Garage S3 endpoint
        3902  # Garage S3 web
        3903  # Garage admin
      ];
    };

    # Users
    users.users = {
      nullstring1 = {
        openssh.authorizedKeys.keys = authorizedKeys;
      };
    };

    # Sops secrets for tunnels
    sops.secrets.cloudflaredTunnelToken = { };
    sops.secrets.comtrakTunnelToken = {
      owner = "nullstring1";
    };

    # System services
    systemd.services = {
      # Comtrak Cloudflare tunnel
      comtrak-tunnel = {
        description = "Comtrak Cloudflare Tunnel";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run --token-file \${CREDENTIALS_DIRECTORY}/token";
          LoadCredential = "token:${config.sops.secrets.comtrakTunnelToken.path}";
          Restart = "always";
          RestartSec = 5;
          User = "nullstring1";
        };
      };

      # Main Cloudflare tunnel
      cloudflared = {
        description = "Main Cloudflare Tunnel";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run --token-file \${CREDENTIALS_DIRECTORY}/token";
          LoadCredential = "token:${config.sops.secrets.cloudflaredTunnelToken.path}";
          Restart = "always";
          RestartSec = 5;
        };
      };

      # Comtrak Docker Compose Stack
      comtrak = {
        description = "Comtrak Docker Compose Stack";
        after = [ "docker.service" "network-online.target" ];
        wants = [ "docker.service" "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          WorkingDirectory = "/mdata/NS/Projects/comtrak";
          ExecStart = "${pkgs.docker-compose}/bin/docker-compose -p comtrak -f /mdata/NS/Projects/comtrak/docker-compose.yml -f /mdata/NS/Projects/comtrak/comtrak.prod.yml --env-file /mdata/NS/Projects/comtrak/comtrak-prod.env up -d";
          ExecStop = "${pkgs.docker-compose}/bin/docker-compose -p comtrak -f /mdata/NS/Projects/comtrak/docker-compose.yml -f /mdata/NS/Projects/comtrak/comtrak.prod.yml down";
          User = "nullstring1";
        };
      };
    };
  };
}
