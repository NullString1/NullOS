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
  services = {
    power-profiles-daemon.enable = laptopPowerManagement;
    thermald.enable = laptopPowerManagement;
    upower.enable = laptopPowerManagement;
    tlp = {
      enable = false;
      settings = {
        STOP_CHARGE_THRESH_BAT0 = 100;
      };
    };
  };
  services.logind.settings.Login = mkIf laptopPowerManagement {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "hybrid-sleep";
    HandleLidSwitchDocked = "ignore";
  };
  systemd.sleep.settings.Sleep = mkIf laptopPowerManagement {
    HibernateDelaySec = "30min";
  };
}
