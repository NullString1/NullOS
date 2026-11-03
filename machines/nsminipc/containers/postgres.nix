{ config, pkgs, ... }:
{
  sops.secrets.postgresPassword = { };
  sops.templates."postgres.env".content = ''
    POSTGRES_PASSWORD=${config.sops.placeholder.postgresPassword}
  '';
  virtualisation.oci-containers.containers."postgres" = {
    image = "postgres:15";
    autoStart = true;
    cmd = [
      "postgres"
      "-c"
      "max_connections=1000"
      "-c"
      "listen_addresses=*"
    ];
    environment = {
      POSTGRES_USER = "user";
      POSTGRES_DB = "evolution";
      POSTGRES_HOST_AUTH_METHOD = "trust";
    };
    environmentFiles = [
      config.sops.templates."postgres.env".path
    ];
    volumes = [
      "postgres_data:/var/lib/postgresql/data"
    ];
    ports = [
      "5432:5432"
    ];
    extraOptions = [
      "--network=evolution-net"
    ];
  };
  systemd.services."docker-network-evolution-net" = {
    description = "Create docker network evolution-net for oci-containers";
    after = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.docker}/bin/docker network inspect evolution-net >/dev/null 2>&1 || \
        ${pkgs.docker}/bin/docker network create evolution-net
    '';
  };
}
