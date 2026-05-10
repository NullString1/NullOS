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
    wireless.dbusControlled = true;
    wireless.userControlled = true;
    # wireless.extraConfig = ''
    #   ctrl_interface=DIR=/run/wpa_supplicant GROUP=wheel
    # '';
    #wireless.driver = "nl80211,wext -C /run/wpa_supplicant"; # Inject -C to prevent wpa_supplicant from trying to control the interface itself
    #wireless.interfaces = [ "wlo1" ];
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
        7250
        25565
        8123
      ];
      allowedTCPPortRanges = [ { from = 32768; to = 61000; } ];
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
        7250
        25565
        8123
        1900
        5353
      ];
      extraCommands = ''
        iptables -A INPUT -i p2p-wlo1-+ -j ACCEPT
      '';
      extraStopCommands = ''
        iptables -D INPUT -i p2p-wlo1-+ -j ACCEPT || true
      '';
    };
  };

  environment.systemPackages = with pkgs; [ networkmanagerapplet ];
}
