{ config, lib, vars, ...}:
let 
  localNixpkgs = /home/nullstring1/nixpkgs;
  rtl8852cu = config.boot.kernelPackages.callPackage (localNixpkgs + "/pkgs/os-specific/linux/rtl8852cu") {};
in
{
  boot.extraModulePackages = [ rtl8852cu ];
  boot.kernelModules = [ "rtl8852cu" ];
  boot.extraModprobeConfig =
    lib.mkIf vars.add_rtl8852cu ''
      options 8852cu rtw_switch_usb_mode=1
      options 8852cu rtw_country_code=GB
      options 8852cu rtw_low_power=0
    '';
  boot.kernelParams = lib.mkIf vars.add_rtl8852cu [ "usbcore.autosuspend=-1" ];
}
