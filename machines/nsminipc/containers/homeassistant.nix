{ ... }:
{
  virtualisation.oci-containers.containers."homeassistant" = {
    image = "ghcr.io/home-assistant/home-assistant:stable";
    autoStart = true;
    volumes = [
      "/home/nullstring1/home-assistant/config:/config:rw"
      "/etc/localtime:/etc/localtime:ro"
      "/run/dbus:/run/dbus:ro"
    ];
    environment = {
      TZ = "Europe/London";
    };
    extraOptions = [
      "--network=host"
      "--privileged"
      "--cap-add=NET_ADMIN"
      "--cap-add=NET_RAW"
    ];
  };
}
