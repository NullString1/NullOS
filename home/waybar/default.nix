{
  pkgs,
  lib,
  ...
}:
let
  terminal = "ghostty";
  base00 = "0F1419";
  base01 = "131721";
  base03 = "3E4B59";
  base05 = "E6E1CF";
  base06 = "E6E1CF";
  base07 = "F3F4F5";
  base08 = "F07178";
  base09 = "FF8F40";
  base0A = "FFB454";
  base0B = "B8CC52";
  base0C = "95E6CB";
  base0D = "59C2FF";
  base0E = "D2A6FF";
  base0F = "E6B673";
in
with lib;
{
  # Configure & Theme Waybar
  home.packages = with pkgs; [ msr-tools ];
  programs = {
    waybar = {
      enable = true;
      package = pkgs.waybar;
      settings = [
        {
          layer = "top";
          position = "top";

          modules-left = [
            "custom/startmenu"
            "tray"
            "hyprland/window"
          ];
          modules-center = [ "hyprland/workspaces" ];
          modules-right = [
            "idle_inhibitor"
            "custom/notification"
            "pulseaudio"
            "cpu"
            "memory"
            "disk"
            "network"
            "battery"
            "custom/tlp"
            "clock"
            "custom/exit"
          ];

          "hyprland/workspaces" = {
            format = "{name}";
            format-icons = {
              default = " ";
              active = " ";
              urgent = " ";
            };
            on-scroll-up = "hyprctl dispatch workspace e+1";
            on-scroll-down = "hyprctl dispatch workspace e-1";
          };
          "clock" = {
            format = " {:%H:%M}";
            # ''{: %I:%M %p}'';
            tooltip = true;
            tooltip-format = "<big>{:%A, %d.%B %Y }</big><tt><small>{calendar}</small></tt>";
          };
          "hyprland/window" = {
            max-length = 60;
            separate-outputs = false;
          };
          "memory" = {
            interval = 5;
            format = " {}%";
            tooltip = true;
            on-click = "${terminal} -e btop";
          };
          "cpu" = {
            interval = 5;
            format = " {usage:2}%";
            tooltip = true;
            on-click = "${terminal} -e btop";
          };
          "disk" = {
            format = " {free}";
            tooltip = true;
            on-click = "${terminal} -e sh -c df -h ; read";
          };
          "network" = {
            format-icons = [
              "󰤯"
              "󰤟"
              "󰤢"
              "󰤥"
              "󰤨"
            ];
            format-ethernet = " {bandwidthDownBits}";
            format-wifi = " {bandwidthDownBits}";
            format-disconnected = "󰤮";
            tooltip = false;
            on-click = "${terminal} -e btop";
          };
          "tray" = {
            spacing = 12;
          };
          "pulseaudio" = {
            format = "{icon} {volume}% {format_source}";
            format-bluetooth = "{volume}% {icon} {format_source}";
            format-bluetooth-muted = " {icon} {format_source}";
            format-muted = " {format_source}";
            format-source = " {volume}%";
            format-source-muted = "";
            format-icons = {
              headphone = "";
              hands-free = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = [
                ""
                ""
                ""
              ];
            };
            on-click = "pavucontrol";
          };
          "custom/exit" = {
            tooltip = false;
            format = "⏻";
            on-click = "wlogout";
          };
          "custom/startmenu" = {
            tooltip = false;
            format = " ";
            on-click = "rofi -show drun";
          };
          "idle_inhibitor" = {
            format = "{icon}";
            format-icons = {
              activated = " ";
              deactivated = " ";
            };
            tooltip = "true";
          };
          "custom/tlp" = {
            tooltip = true;
            tooltip-format = "{}";
            format = "{icon} {text}";
            format-icons = {
              "Battery (auto)" = "✨";
              "AC (auto)" = "✨";
              "AC (manual)" = "🔌";
              "Battery (manual)" = "🔋";
            };
            return-type = "json";
            exec = pkgs.writeShellScript "tlp-status" ''
              mode=$(${pkgs.tlp}/bin/tlp-stat -s 2>/dev/null | grep 'Mode' | awk '{print $3 $4}' | tr '[:upper:]' '[:lower:]')
              case "$mode" in
                "battery(manual)" ) mode="Battery (manual)" ;;
                "battery" ) mode="Battery (auto)" ;;
                "ac(manual)" ) mode="AC (manual)" ;;
                "ac" ) mode="AC (auto)" ;;
              esac

              # Get power consumption
              power_now=""
              power_text=""

              # Try battery power_now first (for discharging)
              if [ -f /sys/class/power_supply/BAT*/power_now ]; then
                power_uw=$(cat /sys/class/power_supply/BAT*/power_now 2>/dev/null | head -1)
                if [ -n "$power_uw" ] && [ "$power_uw" != "0" ]; then
                  power_w=$(echo "scale=1; $power_uw / 1000000" | bc 2>/dev/null || echo "0.0")
                  power_now=" $power_w W"
                  power_text="$power_w W"
                fi
              fi

              # If no battery power or plugged in, try RAPL MSR reading as fallback
              if [ -z "$power_now" ]; then
                # Try fast RAPL MSR reading for CPU package power
                if command -v rdmsr >/dev/null 2>&1; then
                  rapl_w=$(sudo bash -c 'start=$(rdmsr -d 0x611); sleep 1; end=$(rdmsr -d 0x611); esu=$((1<<($(rdmsr -d 0x606) >> 8 & 0x1f))); printf "%.2f W\n" $(echo "($end - $start) / $esu" | bc -l)' 2>/dev/null)
                  if [ -n "$rapl_w" ] && [ "$rapl_w" != "0.00" ]; then
                    power_now=" ~$rapl_w"
                    power_text="~$rapl_w"
                  fi
                fi
              fi

              tooltip="$mode$power_now"
              printf '{"text": "%s", "alt": "%s", "class": "%s", "tooltip": "%s"}\n' "$power_text" "$mode" "$mode" "$tooltip"
            '';
            interval = 10;
            on-click = pkgs.writeShellScript "tlp-toggle" ''
              current=$(${pkgs.tlp}/bin/tlp-stat -s 2>/dev/null | grep 'Mode' | awk '{print $3 $4}' | tr '[:upper:]' '[:lower:]')
              case "$current" in
                "battery" ) sudo ${pkgs.tlp}/bin/tlp ac ;;
                "battery(manual)" | "ac(manual)" ) sudo ${pkgs.tlp}/bin/tlp start ;;
                "ac" ) sudo ${pkgs.tlp}/bin/tlp bat ;;
              esac
            '';
          };
          "custom/notification" = {
            tooltip = false;
            format = "{icon} {text}";
            format-icons = {
              notification = "<span foreground='red'><sup></sup></span>";
              none = "";
              dnd-notification = "<span foreground='red'><sup></sup></span>";
              dnd-none = "";
              inhibited-notification = "<span foreground='red'><sup></sup></span>";
              inhibited-none = "";
              dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
              dnd-inhibited-none = "";
            };
            return-type = "json";
            exec-if = "which swaync-client";
            exec = "swaync-client -swb";
            on-click = "swaync-client -t";
            escape = true;
          };
          "battery" = {
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{icon} {capacity}%";
            format-charging = "󰂄 {capacity}%";
            format-plugged = "󱘖 {capacity}%";
            format-icons = [
              "󰁺"
              "󰁻"
              "󰁼"
              "󰁽"
              "󰁾"
              "󰁿"
              "󰂀"
              "󰂁"
              "󰂂"
              "󰁹"
            ];
            on-click = "";
            tooltip = false;
          };
        }
      ];
      style = concatStrings [
        ''
          * {
            font-size: 16px;
            font-family: JetBrainsMono Nerd Font, Font Awesome, sans-serif;
            font-weight: bold;
          }
          window#waybar {
            /*

              background-color: rgba(26,27,38,0);
              border-bottom: 1px solid rgba(26,27,38,0);
              border-radius: 0px;
              color: #${base0F};
            */

            background-color: rgba(26,27,38,0);
            border-bottom: 1px solid rgba(26,27,38,0);
            border-radius: 0px;
            color: #${base0F};
          }
          #workspaces {
            /*
              Eternal
              background: linear-gradient(180deg, #${base00}, #${base01});
              margin: 5px 5px 5px 0px;
              padding: 0px 10px;
              border-radius: 0px 15px 15px 0px;
              border: 0px;
              font-style: normal;
              color: #${base00};
            */
            background: linear-gradient(45deg, #${base01}, #${base01});
            margin: 5px;
            padding: 0px 1px;
            border-radius: 15px;
            border: 0px;
            font-style: normal;
            color: #${base00};
          }
          #workspaces button {
            padding: 0px 5px;
            margin: 4px 3px;
            border-radius: 15px;
            border: 0px;
            color: #${base00};
            background: linear-gradient(45deg, #${base0D}, #${base0E});
            opacity: 0.5;
            transition: all 0.3s ease-in-out;
          }
          #workspaces button.active {
            padding: 0px 5px;
            margin: 4px 3px;
            border-radius: 15px;
            border: 0px;
            color: #${base00};
            background: linear-gradient(45deg, #${base0D}, #${base0E});
            opacity: 1.0;
            min-width: 40px;
            transition: all 0.3s ease-in-out;
          }
          #workspaces button:hover {
            border-radius: 15px;
            color: #${base00};
            background: linear-gradient(45deg, #${base0D}, #${base0E});
            opacity: 0.8;
          }
          tooltip {
            background: #${base00};
            border: 1px solid #${base0E};
            border-radius: 10px;
          }
          tooltip label {
            color: #${base07};
          }
          #window {
            /*
              Eternal
              color: #${base05};
              background: #${base00};
              border-radius: 15px;
              margin: 5px;
              padding: 2px 20px;
            */
            margin: 5px;
            padding: 2px 20px;
            color: #${base05};
            background: #${base01};
            border-radius: 15px 15px 15px 15px;
          }
          #memory {
            color: #${base0F};
            /*
              Eternal
              background: #${base00};
              border-radius: 15px 15px 15px 15px;
              margin: 5px;
              padding: 2px 20px;
            */
            background: #${base01};
            margin: 5px 2.5px;
            padding: 2px 20px;
            border-radius: 15px 15px 15px 15px;
          }
          #clock {
            color: #${base0B};
              background: #${base00};
              border-radius: 15px 15px 15px 15px;
              margin: 5px 2.5px;
              padding: 2px 20px;
          }
          #idle_inhibitor {
            color: #${base0A};
              background: #${base00};
              border-radius: 15px 15px 15px 15px;
              margin: 3px 1.5px;
              padding: 2px 20px;
          }
          #cpu {
            color: #${base07};
              background: #${base00};
              border-radius: 15px 15px 15px 15px;
              margin: 5px 2.5px;
              padding: 2px 20px;
          }
          #disk {
            color: #${base0F};
              background: #${base00};
              border-radius: 15px 15px 15px 15px;
              margin: 5px 2.5px;
              padding: 2px 20px;
          }
          #battery {
            color: #${base08};
            background: #${base00};
            border-radius: 15px 15px 15px 15px;
            margin: 5px 2.5px;
            padding: 2px 20px;
          }
          #network {
            color: #${base09};
            background: #${base00};
            border-radius: 15px 15px 15px 15px;
            margin: 5px 2.5px;
            padding: 2px 20px;
          }
          #tray {
            color: #${base05};
            background: #${base00};
            border-radius: 15px 15px 15px 15px;
            margin: 5px;
            padding: 2px 15px;
          }
          #pulseaudio {
            color: #${base0D};
            /*
              Eternal
              background: #${base00};
              border-radius: 15px 15px 15px 15px;
              margin: 5px;
              padding: 2px 20px;
            */
            background: #${base01};
            margin: 4px 2px;
            padding: 2px 20px;
            border-radius: 15px 15px 15px 15px;
          }
          #custom-notification {
            color: #${base0C};
            background: #${base00};
            border-radius: 15px 15px 15px 15px;
            margin: 5px 2.5px;
            padding: 2px 20px;
          }
          #custom-tlp {
            color: #${base0A};
            background: #${base00};
            border-radius: 15px 15px 15px 15px;
            margin: 5px 2.5px;
            padding: 2px 10px;
          }
          #custom-startmenu {
            color: #${base0E};
            background: #${base00};
            border-radius: 0px 15px 15px 0px;
            margin: 5px 5px 5px 0px;
            padding: 2px 20px;
          }
          #custom-exit {
            color: #${base0E};
            background: #${base00};
            border-radius: 15px 0px 0px 15px;
            margin: 5px 0px 5px 2.5px;
            padding: 2px 20px;
          }
        ''
      ];
    };
    jq.enable = true;
  };
}
