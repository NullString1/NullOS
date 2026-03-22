{ vars, ... }:
{
  services = {
    printing = {
      enable = vars.printEnable;
      drivers = vars.printDrivers;
    };
    ipp-usb.enable = vars.printEnable;
  };
}
