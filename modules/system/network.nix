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
      ];
      allowedUDPPorts = [
        59010
        59011
        161
        162
        9100
      ];
    };
  };

  environment.systemPackages = with pkgs; [ networkmanagerapplet ];
}
