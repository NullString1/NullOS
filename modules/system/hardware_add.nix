{
  pkgs,
  config,
  vars,
  lib,
  ...
}:
let
  rtl8852cu-package = pkgs.callPackage ./rtl8852cu.nix {
    kernel = config.boot.kernelPackages.kernel;
  };
in
{
  boot.extraModulePackages = lib.mkIf vars.add_rtl8852cu [ rtl8852cu-package ];
  boot.extraModprobeConfig =
    lib.mkIf vars.add_rtl8852cu ''
      options 8852cu rtw_switch_usb_mode=1
      options 8852cu rtw_country_code=GB
      options 8852cu rtw_low_power=0
    '';
  boot.kernelParams = lib.mkIf vars.add_rtl8852cu [ "usbcore.autosuspend=-1" ];
  boot.kernelModules = lib.mkIf vars.add_rtl8852cu [ "8852cu" ];
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
