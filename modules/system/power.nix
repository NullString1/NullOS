{ ... }:
{
  powerManagement = {
    cpuFreqGovernor = "powersave";
    enable = true;
    powertop.enable = false;
  };
  services.power-profiles-daemon.enable = true;
}
