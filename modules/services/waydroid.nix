{
  pkgs,
  vars,
  ...
}:
let
  waydroid-atv-init = pkgs.writeShellScriptBin "waydroid-atv-init" ''
    echo "Initializing Waydroid with Android TV LineageOS images..."
    sudo systemctl stop waydroid-container 2>/dev/null || true

    sudo waydroid init -f \
      -c https://waydroid-atv.github.io/ota/a16-tv/system \
      -v https://waydroid-atv.github.io/ota/a16-tv/vendor \
      -r lineage \
      -s GAPPS

    echo "Android TV initialization complete!"
  '';

  restart-waydroid = pkgs.writeShellScriptBin "restart-waydroid" ''
    echo "Restarting Waydroid session..."
    waydroid session stop || true
    sudo systemctl restart cage-tty1.service || true
    sleep 5
    waydroid status
  '';

  waydroid-cage-wrapper = pkgs.writeShellScriptBin "waydroid-cage-wrapper" ''
    set -e
    trap 'waydroid session stop' EXIT

    # Export user dbus and runtime dir
    export XDG_RUNTIME_DIR="/run/user/$(id -u)"
    export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"

    # Force Cage's active output to 1080p over wlroots IPC
    ${pkgs.wlr-randr}/bin/wlr-randr --output HDMI-A-2 --mode 1920x1080@60Hz || true

    # Start background session daemon
    waydroid session start &

    # Wait until container and session are actually reported RUNNING
    echo "Waiting for Waydroid session..."
    while ! waydroid status 2>/dev/null | grep -q "Session:.*RUNNING"; do
      sleep 1
    done

    # Reset any wm scaling overrides so Android renders 1:1 at 1080p
    waydroid shell wm size reset 2>/dev/null || true
    waydroid shell wm density reset 2>/dev/null || true

    # Wake up Android and display full UI
    waydroid shell input keyevent KEYCODE_WAKEUP 2>/dev/null || true
    exec waydroid show-full-ui
  '';
in
{
  virtualisation.waydroid = {
    enable = true;
    package = pkgs.waydroid-nftables;
  };

  environment.systemPackages = with pkgs; [
    waydroid-nftables
    waydroid-atv-init
    waydroid-cage-wrapper
    restart-waydroid
    wlr-randr
    cage
  ];

  # Protect Android 32-bit Bionic libc from PID exhaustion crashes
  boot.kernel.sysctl = {
    "kernel.pid_max" = 65535;
  };

  # Lock HDMI output digitally ON and force 1080p on boot
  boot.kernelParams = [
    "video=HDMI-A-2:1920x1080@60D"
  ];

  services.cage = {
    enable = true;
    user = vars.username;
    program = "${waydroid-cage-wrapper}/bin/waydroid-cage-wrapper";
    extraArguments = [
      "-d"
      "-s"
    ];
    environment = {
      WLR_LIBINPUT_NO_DEVICES = "1";
      #WLR_DRM_NO_ATOMIC = "1";
      #WLR_DRM_NO_DIRECT_SCANOUT = "1";
      #WLR_DRM_NO_MODIFIERS = "1";
      WLR_NO_HARDWARE_CURSORS = "1";
      WLR_BACKENDS = "drm,libinput";
      XDG_SESSION_TYPE = "wayland";
      WLR_RENDERER = "gles2";
      WLR_SCENE_DISABLE_DIRECT_SCANOUT = "1";
    };
  };

  # Bluetooth stack setup for automatic DS4 auto-reconnection
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        FastConnectable = "true";
        AutoEnable = "true";
        JustWorksRepairing = "always";
      };
      Policy = {
        AutoEnable = "true";
      };
      Input = {
        UserspaceHID = "false";
        ClassicBondedOnly = "false";
      };
    };
  };

  systemd.services.bluez-headless-agent = {
    description = "BlueZ Default Agent and Page Scan Keepalive";
    after = [ "bluetooth.service" ];
    requires = [ "bluetooth.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStartPre = "${pkgs.bluez}/bin/btmgmt connectable on";
      # bt-agent stays running in the foreground and registers as default agent
      ExecStart = "${pkgs.bluez-tools}/bin/bt-agent -c NoInputNoOutput";
      Restart = "always";
      RestartSec = 2;
    };
  };

  users.users.${vars.username}.extraGroups = [
    "video"
    "render"
    "input"
    "seat"
  ];

  services.seatd.enable = true;

  systemd.services.cage-tty1 = {
    after = [
      #"waydroid-container.service"
      "seatd.service"
      "systemd-user-sessions.service"
    ];
    wants = [
      #"waydroid-container.service"
      "seatd.service"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "2s";
      CPUSchedulingPolicy = "rr";
      CPUSchedulingPriority = 20;
      IOSchedulingClass = "realtime";
      IOSchedulingPriority = 0;
    };
  };
  systemd.services.waydroid-container = {
    serviceConfig = {
      IOSchedulingClass = "best-effort";
      IOSchedulingPriority = 1;
      Restart = "on-failure";
      RestartSec = "2s";
    };
  };
}
