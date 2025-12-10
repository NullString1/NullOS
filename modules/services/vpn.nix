{ pkgs, ... }:
{
  services = {
    tailscale = {
      enable = true;
      useRoutingFeatures = "both";
    };
    mullvad-vpn = {
      enable = true;
      package = pkgs.mullvad-vpn;
    };
    cloudflare-warp = {
      enable = true;
    };
  };
  environment.systemPackages = [ pkgs.riseup-vpn ];
}
