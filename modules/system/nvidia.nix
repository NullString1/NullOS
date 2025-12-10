{
  lib,
  vars,
  config,
  ...
}:
with lib;
{
  services.xserver.videoDrivers = [ "nvidia" ];
  services.supergfxd.enable = true;
  hardware.nvidia = mkIf vars.useNvidiaPrime {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      intelBusId = vars.intelBusId;
      nvidiaBusId = vars.nvidiaBusId;
    };
  };
}
