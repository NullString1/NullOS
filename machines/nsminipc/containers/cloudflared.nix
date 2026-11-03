{ config, ... }:
{
  sops.secrets.cloudflaredTunnelToken = { };
  sops.templates."cloudflared.env".content = ''
    TUNNEL_TOKEN=${config.sops.placeholder.cloudflaredTunnelToken}
  '';
  virtualisation.oci-containers.containers."cloudflared" = {
    image = "cloudflare/cloudflared:latest";
    autoStart = true;
    cmd = [
      "tunnel"
      "--no-autoupdate"
      "run"
    ];
    environmentFiles = [
      config.sops.templates."cloudflared.env".path
    ];
    extraOptions = [
      "--network=host"
    ];
  };
}
