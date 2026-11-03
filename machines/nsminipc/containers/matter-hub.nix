{ config, ... }:
{
  sops.secrets.matterHubAccessToken = { };
  sops.templates."matter-hub.env".content = ''
    HAMH_HOME_ASSISTANT_ACCESS_TOKEN=${config.sops.placeholder.matterHubAccessToken}
  '';
  virtualisation.oci-containers.containers."matter-hub" = {
    image = "ghcr.io/riddix/home-assistant-matter-hub:latest";
    autoStart = true;
    volumes = [
      "/home/nullstring1/home-assistant/home-assistant-matter-hub:/data:rw"
    ];
    environment = {
      HAMH_HOME_ASSISTANT_URL = "https://home.nullstring.one";
      HAMH_LOG_LEVEL = "info";
      HAMH_HTTP_PORT = "8482";
    };
    environmentFiles = [
      config.sops.templates."matter-hub.env".path
    ];
    extraOptions = [
      "--network=host"
    ];
  };
}
