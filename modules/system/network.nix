{
  vars,
  options,
  pkgs,
  config,
  ...
}:
{
  networking = {
    hostName = "${vars.hostname}";
    networkmanager = {
      enable = true;
    };
    wireless = {
      enable = true;
      dbusControlled = true;
      userControlled = true;
    };
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
      allowedTCPPortRanges = [
        {
          from = 32768;
          to = 61000;
        }
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
      trustedInterfaces = [ "tailscale0" ];
    };
  };

  assertions = [
    {
      assertion = !(vars.enableWayVNC && builtins.elem 5900 config.networking.firewall.allowedTCPPorts);
      message = "SECURITY RISK: Port 5900 (VNC) is globally exposed! Remove it from allowedTCPPorts.";
    }
  ];

  boot.initrd.systemd.network.wait-online.enable = false;
  systemd.network.wait-online.enable = false;

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="1a2b", RUN+="${pkgs.usb-modeswitch}/bin/usb_modeswitch -K -v 0bda -p 1a2b"
  '';

  environment.systemPackages = with pkgs; [ networkmanagerapplet ];
}
