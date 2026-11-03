{ ... }:
{
  virtualisation.oci-containers.containers."evolution_api" = {
    image = "evoapicloud/evolution-api:latest";
    autoStart = true;
    dependsOn = [ "postgres" ];
    # String (not a path literal): keeps the host file out of the Nix
    # store and keeps pure evaluation (`nix flake check`) working.
    # At runtime docker reads /home/nullstring1/home-assistant/.env
    # from the host as before.
    environmentFiles = [
      "/home/nullstring1/home-assistant/.env"
    ];
    volumes = [
      "evolution_instances:/evolution/instances"
    ];
    ports = [
      "8080:8080"
    ];
    extraOptions = [
      "--network=evolution-net"
      "--expose=8080"
    ];
  };
}
