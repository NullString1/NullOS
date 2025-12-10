{ vars, ... }:
{
  services = {
    printing = {
      enable = vars.printEnable;
      drivers = vars.printDrivers;
    };
    avahi = {
      enable = vars.printEnable;
      nssmdns4 = true;
      openFirewall = true;
    };
    ipp-usb.enable = vars.printEnable;
  };
}
