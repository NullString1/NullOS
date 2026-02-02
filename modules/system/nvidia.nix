{
  lib,
  vars,
  config,
  ...
}:
with lib;
{
  services.xserver.videoDrivers = mkIf (vars.useNvidia) [ "nvidia" ];
  services.supergfxd.enable = vars.useNvidia;
  hardware.nvidia = mkIf (vars.useNvidiaPrime && vars.useNvidia) {
    modesetting.enable = true;
    powerManagement = {
      enable = true;
      finegrained = false;
    };
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      intelBusId = vars.intelBusId;
      nvidiaBusId = vars.nvidiaBusId;
    };
  };
}
