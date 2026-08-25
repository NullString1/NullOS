{
  vars,
  lib,
  ...
}:
let
  inherit (vars) isHyprland;
  inherit (lib) mkIf;
in
{
  xdg.portal.config.common = mkIf isHyprland {
    "org.freedesktop.impl.portal.RemoteDesktop" = "hypr-kdeconnect";
  };
  networking.firewall = {
    allowedTCPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
    allowedUDPPortRanges =
      [
        {
          from = 1714;
          to = 1764;
        }
      ];
  };
  services.hypr-kdeconnect-fix.enable = isHyprland;
}
