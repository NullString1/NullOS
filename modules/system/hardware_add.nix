{
  pkgs,
  config,
  vars,
  ...
}:
let
  rtl8852cu-package = pkgs.callPackage ./rtl8852cu.nix {
    kernel = config.boot.kernelPackages.kernel;
  };
in
{
  boot.extraModulePackages = if vars.add_rtl8852cu then [ rtl8852cu-package ] else [ ];
  boot.extraModprobeConfig =
    if vars.add_rtl8852cu then
      ''
        options 8852cu rtw_switch_usb_mode=1
        options 8852cu rtw_country_code=GB
        options 8852cu rtw_low_power=0
      ''
    else
      "";
  boot.kernelParams = if vars.add_rtl8852cu then [ "usbcore.autosuspend=-1" ] else [ ];
  boot.kernelModules = if vars.add_rtl8852cu then [ "8852cu" ] else [ ];
  hardware = {
    usb-modeswitch.enable = true;
    firmware = [ pkgs.sof-firmware ];
    sane = {
      enable = true;
      extraBackends = [ pkgs.sane-airscan ];
      disabledDefaultBackends = [ "escl" ];
    };
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        nvidia-vaapi-driver
        vulkan-loader
        gamemode
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [
        vulkan-loader
        gamemode
        nvidia-vaapi-driver
        intel-vaapi-driver
        intel-media-driver
      ];
    };
    enableRedistributableFirmware = true;
    keyboard.qmk.enable = true;
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
  };
}
