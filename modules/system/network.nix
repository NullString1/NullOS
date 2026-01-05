{
  pkgs,
  vars,
  options,
  ...
}:
{
  networking = {
    hostName = "${vars.hostname}";
    networkmanager.enable = true;
    networkmanager.settings = if vars.add_rtl8852cu then {
      wifi.powersave = false;
    } else {};
    timeServers = options.networking.timeServers.default ++ [ "pool.ntp.org" ];
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        80
        443
        59010
        59011
        8080
        161
        162
        9100
	      11470
        7236
        7237
        7238
      ];
      allowedUDPPorts = [
        59010
        59011
        161
        162
        9100
	      11470
        7236
        7237
        7238
      ];
    };
  };

  environment.systemPackages = with pkgs; [ networkmanagerapplet ];
}
