{
  vars,
  options,
  pkgs,
  ...
}:
{
  networking = {
    hostName = "${vars.hostname}";
    networkmanager.enable = true;
    timeServers = options.networking.timeServers.default ++ [ "pool.ntp.org" ];
    firewall = {
      enable = true;
      checkReversePath = "loose";
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
        25565
        8123
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
        25565
        8123
      ];
    };
  };

  environment.systemPackages = with pkgs; [ networkmanagerapplet ];
}
