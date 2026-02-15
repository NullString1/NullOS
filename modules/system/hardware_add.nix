{
  pkgs,
  ...
}:
{
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
