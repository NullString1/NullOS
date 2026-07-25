{ vars, lib, ... }:
let
  inherit (vars) laptopPowerManagement;
  inherit (lib) mkIf;
in
{
  powerManagement = {
    cpuFreqGovernor = mkIf laptopPowerManagement "powersave";
    enable = true;
  };
  services.power-profiles-daemon.enable = laptopPowerManagement;
  services.logind.settings.Login = mkIf laptopPowerManagement {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "hybrid-sleep";
    HandleLidSwitchDocked = "ignore";
  };
  systemd.sleep.settings.Sleep = mkIf laptopPowerManagement {
    HibernateDelaySec = "30min";
  };
}
