{ ... }:

{
  services = {
    hypridle = {
      enable = true;
      settings = {
        general = {
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = ''hyprctl dispatch 'hl.dsp.dpms({ action = "on" })' '';
          ignore_dbus_inhibit = false;
          lock_cmd = "pidof hyprlock || hyprlock";
        };
        listener = [
          {
            timeout = 900;
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 1200;
            on-timeout = ''hyprctl dispatch 'hl.dsp.dpms({ action = "off" })' '';
            on-resume = ''hyprctl dispatch 'hl.dsp.dpms({ action = "on" })' '';
          }
          {
            timeout = 1800;
            on-timeout = "systemctl suspend-then-hibernate";
          }
        ];
      };
    };
  };
}
