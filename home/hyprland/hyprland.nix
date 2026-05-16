{
  lib,
  pkgs,
  vars,
  ...
}:
let
  red = "f38ba8";
  blue = "89b4fa";
  surface1 = "313244";
in
{
  home.packages = with pkgs; [
    grim
    slurp
    wl-clipboard
    cliphist
    swappy
    ydotool
    hyprpolkitagent
    hyprland-qtutils
    hyprpicker
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
  services.hyprpaper = {
    enable = true;
    settings = {
      splash = false;
      wallpaper = [
        {
          monitor = "eDP-1";
          path = "${vars.stylixImage}";
          fit_mode = "cover";
        }
      ];
    };
  };
  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    configType = "lua";
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
      on = {
        _args = [
          "hyprland.start"
          (lib.generators.mkLuaInline ''
            function()
              hl.exec_cmd("wl-paste --type text --watch cliphist store")
              hl.exec_cmd("wl-paste --type image --watch cliphist store")
              hl.exec_cmd("dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
              hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
              hl.exec_cmd("systemctl --user start hyprpolkitagent")
              hl.exec_cmd("systemctl --user start blueman-applet")
              hl.exec_cmd("systemctl --user start warp-taskbar")
              hl.exec_cmd("systemctl --user start wayvnc")
              hl.exec_cmd("killall -q hyprpaper; sleep .5 && hyprpaper &")
              hl.exec_cmd("killall -q waybar; sleep .5 && waybar")
              hl.exec_cmd("killall -q swaync; sleep .5 && swaync")
              hl.exec_cmd("nm-applet --indicator")
              hl.exec_cmd("swayosd-server &")
              hl.exec_cmd("pypr &")
              hl.exec_cmd("sleep 1.5 && hyprctl hyprpaper wallpaper 'eDP-1,${vars.stylixImage},cover'")
              hl.exec_cmd("sleep 2 && hyprctl setcursor Bibata-Modern-Ice 24")
            end
          '')
        ];
      };

      config = {
        cursor = {
          warp_on_change_workspace = 2;
        };
        decoration = {
          rounding = 10;
          blur = {
            enabled = true;
            size = 5;
            passes = 3;
            ignore_opacity = false;
          };
          shadow = {
            enabled = true;
            color = "rgba(1a1a1aee)";
          };
        };
        dwindle = {
          preserve_split = true;
          force_split = 2;
        };
        xwayland = {
          enabled = true;
          create_abstract_socket = true;
        };
        ecosystem = {
          no_donation_nag = true;
          no_update_news = false;
        };
        general = {
          allow_tearing = true;
          layout = "master";
          gaps_in = 4;
          gaps_out = 8;
          resize_on_border = true;
          col = {
            active_border = {
              colors = [
                "rgba(${red}ff)"
                "rgba(${blue}ff)"
              ];
              angle = 45;
            };
            inactive_border = "rgba(${surface1}ff)";
          };
        };
        input = {
          accel_profile = "flat";
          kb_layout = "${vars.keyboardLayout}";
          kb_options = "grp:alt_caps_toggle,caps:super";
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
        master = {
          new_on_top = 1;
          mfact = 0.5;
        };
        misc = {
          layers_hog_keyboard_focus = true;
          initial_workspace_tracking = 0;
          mouse_move_enables_dpms = true;
          key_press_enables_dpms = true;
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          enable_swallow = false;
          vrr = 1;
          enable_anr_dialog = true;
          anr_missed_pings = 20;
        };
        render = {
          direct_scanout = 2; # on for game
          new_render_scheduling = true;
          use_fp16 = 1; # enabled
        };
      };

      monitor = [
        {
          output = "eDP-1";
          mode = "preferred";
          position = "auto";
          scale = 1.0;
        }
      ];
    };
  };
}
