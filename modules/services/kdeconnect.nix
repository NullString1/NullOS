{
  vars,
  ...
}:
let
  inherit (vars) isHyprland;
in
{
  networking.firewall = {
    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
    allowedUDPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
  };
  services.hypr-kdeconnect-fix.enable = isHyprland;
}
