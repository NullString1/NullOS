{
  pkgs,
  vars,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (vars) isHyprland;
in
{
  services.kdeconnect = {
    enable = vars.enableKDEConnect;
    indicator = true;
    package = pkgs.kdePackages.kdeconnect-kde;
  };
  xdg.portal.config.common = mkIf isHyprland {
    "org.freedesktop.impl.portal.RemoteDesktop" = "hypr-kdeconnect";
  };
}
