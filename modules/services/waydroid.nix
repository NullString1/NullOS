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

  waydroid-voice = pkgs.writeShellScriptBin "waydroid-voice" ''
    set -euo pipefail
    export XDG_RUNTIME_DIR="/run/user/$(id -u)"
    export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"

    # `waydroid shell` (lxc-attach) requires root; nullstring1 has NOPASSWD sudo.
    # The `--` is required: waydroid's argparse rejects dashed args (e.g. -a/--es) without it.
    wsh() {
      sudo -n waydroid shell -- "$@"
    }

    urlencode() {
      # minimal encode for adb VIEW URIs: spaces -> %20, strip quotes
      printf '%s' "$1" | sed -e 's/"/""/g' -e 's/ /%20/g'
    }

    usage() {
      echo "usage: waydroid-voice search <query> | stremio-search <query> | key <code> | vol-up | vol-down | mute | play-pause | next | prev | up | down | left | right | center | back | home" >&2
      exit 1
    }

    [ $# -ge 1 ] || usage
    mode="$1"; shift || true

    case "$mode" in
      search)
        [ $# -ge 1 ] || usage
        query="$*"
        wsh am start -a "android.search.action.GLOBAL_SEARCH" --es query "play $query on stremio"
        sleep 3
        wsh input keyevent 23
        ;;
      stremio-search)
        [ $# -ge 1 ] || usage
        query="$(urlencode "$*")"
        wsh am start -a android.intent.action.VIEW -d "stremio:///search?query=$query" com.nuvio.tv
        ;;
      key)
        [ $# -eq 1 ] || usage
        case "$1" in '''|*[!0-9]*) usage ;; esac
        wsh input keyevent "$1"
        ;;
      vol-up) wsh input keyevent 24 ;;
      vol-down) wsh input keyevent 25 ;;
      mute) wsh input keyevent 164 ;;
      play-pause) wsh input keyevent 85 ;;
      next) wsh input keyevent 87 ;;
      prev) wsh input keyevent 88 ;;
      up) wsh input keyevent 19 ;;
      down) wsh input keyevent 20 ;;
      left) wsh input keyevent 21 ;;
      right) wsh input keyevent 22 ;;
      center) wsh input keyevent 23 ;;
      back) wsh input keyevent 4 ;;
      home) wsh input keyevent 3 ;;
      *)
        usage
        ;;
    esac
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
    sudo -n waydroid shell -- input keyevent KEYCODE_WAKEUP 2>/dev/null || true
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
    waydroid-voice
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
      WLR_BACKENDS = "drm";
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

  # Fire TV remote (0171:0413) reaches Android via evdev passthrough; hide it from
  # cage's libinput so keys aren't also sent through the Wayland bridge (duplicate inputs),
  # and strip power-switch tag so systemd-logind does not shut down the host on power press.
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="input", ATTRS{id/vendor}=="0171", ATTRS{id/product}=="0413", ENV{LIBINPUT_IGNORE_DEVICE}="1", TAG-="power-switch"
  '';

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
