{ ... }:
{
  powerManagement = {
    cpuFreqGovernor = "powersave";
    enable = true;
  };
  services.power-profiles-daemon.enable = true;
}
