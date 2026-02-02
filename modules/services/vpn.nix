{ pkgs, vars, ... }:
{
  services = {
    tailscale = {
      enable = vars.enableTailscale;
      useRoutingFeatures = "both";
    };
    mullvad-vpn = {
      enable = vars.enableMullvadVPN;
      package = pkgs.mullvad-vpn;
    };
    cloudflare-warp = {
      enable = vars.enableCloudflareWarp;
    };
  };
  environment.systemPackages = pkgs.lib.mkIf vars.enableOpenFortiVPN [ pkgs.openfortivpn ];
}
