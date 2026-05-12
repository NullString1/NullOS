{
  config,
  pkgs,
  vars,
  ...
}:
let
  # Catppuccin Mocha colors
  red = "f38ba8";
  blue = "89b4fa";
  mauve = "cba6f7";
  teal = "94e2d5";
  green = "a6e3a1";
  yellow = "f9e2af";
  peach = "fab387";
  surface1 = "313244";
  base00 = "1e1e2e";
  base01 = "181825";
  base05 = "cdd6f4";
in
{
  home.packages = with pkgs; [
    awww
    grim
    slurp
    wl-clipboard
    swappy
    ydotool
    hyprpolkitagent
    hyprland-qtutils
    hyprpicker
    hyprpaper
  ];
  systemd.user.targets.hyprland-session.Unit.Wants = [
    "xdg-desktop-autostart.target"
  ];
  home.file = {
    "Pictures/Wallpapers" = {
      source = ../../wallpapers;
      recursive = true;
    };
    ".face.icon".source = ./face.jpg;
    ".config/face.jpg".source = ./face.jpg;
    ".local/share/icons/Bibata-Modern-Ice" = {
      source = "${pkgs.bibata-cursors}/share/icons/Bibata-Modern-Ice";
    };
  };
  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    systemd = {
      enable = true;
      enableXdgAutostart = true;
      variables = [
        "--all"
        "XCURSOR_THEME=Bibata-Modern-Ice"
        "XCURSOR_SIZE=24"
      ];
    };
    xwayland = {
      enable = true;
    };
    settings = {
      exec-once = [
        "wl-paste --type text --watch cliphist store # Stores only text data"
        "wl-paste --type image --watch cliphist store # Stores only image data"
        "dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "systemctl --user start hyprpolkitagent"
        "systemctl --user start blueman-applet"
        "systemctl --user start warp-taskbar"
        "killall -q awww;sleep .5 && awww-daemon &"
        "killall -q waybar;sleep .5 && waybar"
        "killall -q swaync;sleep .5 && swaync"
        "nm-applet --indicator"
        "swayosd-server &"
        "pypr &"
        "sleep 1.5 && awww img ${vars.stylixImage}"
        "sleep 2 && hyprctl setcursor Bibata-Modern-Ice 24"
      ];

      input = {
        accel_profile = "flat";
        kb_layout = "${vars.keyboardLayout}";
        kb_options = [
          "grp:alt_caps_toggle"
          "caps:super"
        ];
        numlock_by_default = true;
        repeat_delay = 300;
        follow_mouse = 1;
        float_switch_override_focus = 0;
        sensitivity = 0;
        touchpad = {
          natural_scroll = true;
          disable_while_typing = true;
          scroll_factor = 0.8;
        };
      };

      general = {
        allow_tearing = true;
        layout = "master";
        gaps_in = 4;
        gaps_out = 8;
        border_size = 2;
        resize_on_border = true;
        "col.active_border" = "rgb(${red}) rgb(${blue}) 45deg";
        "col.inactive_border" = "rgb(${surface1})";
      };

      misc = {
        layers_hog_keyboard_focus = true;
        initial_workspace_tracking = 0;
        mouse_move_enables_dpms = true;
        key_press_enables_dpms = false;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        enable_swallow = false;
        vrr = 2;
        enable_anr_dialog = true;
        anr_missed_pings = 20;
      };

      dwindle = {
        preserve_split = true;
        force_split = 2;
      };

      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 5;
          passes = 3;
          ignore_opacity = false;
          new_optimizations = true;
        };
        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };
      };

      ecosystem = {
        no_donation_nag = true;
        no_update_news = false;
      };

      cursor = {
        sync_gsettings_theme = true;
        no_hardware_cursors = 2;
        enable_hyprcursor = false;
        warp_on_change_workspace = 2;
        no_warps = true;
      };

      render = {
        direct_scanout = 0;
      };

      master = {
        new_on_top = 1;
        mfact = 0.5;
      };
    };

    extraConfig = "
      monitor=,preferred,auto,1
      source=~/.config/hypr/monitors.conf
    ";
  };
}
