{
  pkgs,
  vars,
  lib,
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
      enable = !vars.isHeadless;
      enable32Bit = !vars.isHeadless;
      extraPackages =
        with pkgs;
        [
          intel-media-driver
          intel-vaapi-driver
          nvidia-vaapi-driver
          vulkan-loader
        ]
        ++ lib.optionals vars.enableGamemode [ pkgs.gamemode ];
      extraPackages32 =
        with pkgs.pkgsi686Linux;
        [
          vulkan-loader
          nvidia-vaapi-driver
          intel-vaapi-driver
          intel-media-driver
        ]
        ++ lib.optionals vars.enableGamemode [ pkgs.gamemode ];
    };
    enableRedistributableFirmware = true;
    keyboard.qmk.enable = true;
    bluetooth = lib.mkIf vars.enableBluetooth {
      enable = true;
      powerOnBoot = true;
    };
  };
}
