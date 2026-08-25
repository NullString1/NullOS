{
  vars,
  options,
  pkgs,
  config,
  ...
}:
let
  inherit (vars) hostname enableWayVNC;
in
{
  networking = {
    hostName = "${hostname}";
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
        22 # ssh
        11470 # stremio
      ];
      allowedUDPPorts = [
        11470 # stremio
        5353 # mdns
      ];
      trustedInterfaces = [ "tailscale0" ];
    };
  };

  assertions = [
    {
      assertion = !(enableWayVNC && builtins.elem 5900 config.networking.firewall.allowedTCPPorts);
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
