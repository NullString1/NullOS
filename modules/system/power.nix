{ ... }:
{
  powerManagement.cpuFreqGovernor = "powersave";
  powerManagement.enable = true;
  services.power-profiles-daemon.enable = false;
  powerManagement.powertop.enable = false;
  services = {
    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_ENERGY_PERF_POLICY_ON_AC = "ondemand";

        PLATFORM_PROFILE_ON_BAT = "low-power";
        PLATFORM_PROFILE_ON_AC = "ondemand";
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;
        WIFI_PWR_ON_AC = "off";
        WIFI_PWR_ON_BAT = "on";

        NMI_WATCHDOG = 0;

        WOL_DISABLE = "Y";

        SCHED_POWERSAVE_ON_AC = 0;
        SCHED_POWERSAVE_ON_BAT = 1;

        INTEL_GPU_BOOST_FREQ_ON_BAT = 600;
        INTEL_GPU_BOOST_FREQ_ON_AC = 900;
        INTEL_GPU_MIN_FREQ_ON_BAT = 200;
        INTEL_GPU_MIN_FREQ_ON_AC = 300;
        INTEL_GPU_MAX_FREQ_ON_BAT = 900;
        INTEL_GPU_MAX_FREQ_ON_AC = 1200;

        RUNTIME_PM_ON_BAT = "auto";

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 25;

        #Optional helps save long term battery health
        START_CHARGE_THRESH_BAT0 = 40; # 40 and below it starts to charge
        STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging
      };
    };
    auto-cpufreq = {
      enable = false;
      settings = {
        battery = {
          governor = "powersave";
          turbo = "never";
        };
        charger = {
          governor = "performance";
          turbo = "auto";
        };
      };
    };
  };
}
