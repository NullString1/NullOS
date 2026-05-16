{
  lib,
  vars,
  ...
}:
let
  terminal = vars.terminal;
  browser = vars.browser.meta.mainProgram;
in
{
  wayland.windowManager.hyprland.settings = {
    bind = [
      {
        _args = [
          "SUPER + Return"
          (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"${terminal}\")")
        ];
      }
      {
        _args = [
          "SUPER + SHIFT + Return"
          (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"pkill rofi || rofi -show drun\")")
        ];
      }
      {
        _args = [
          "SUPER + D"
          (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"dolphin\")")
        ];
      }
      {
        _args = [
          "SUPER + W"
          (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"${browser}\")")
        ];
      }
      {
        _args = [
          "SUPER + Y"
          (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"${terminal} -e yazi\")")
        ];
      }
      {
        _args = [
          "SUPER + E"
          (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"dolphin\")")
        ];
      }
      {
        _args = [
          "SUPER + S"
          (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"screenshotin\")")
        ];
      }
      {
        _args = [
          "SUPER + SHIFT + S"
          (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"screenshot-ocr\")")
        ];
      }
      {
        _args = [
          "SUPER + C"
          (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"code\")")
        ];
      }
      {
        _args = [
          "SUPER + T"
          (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"pypr toggle term\")")
        ];
      }
      {
        _args = [
          "SUPER + code:51"
          (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"pypr toggle vpn\")")
        ];
      }
      {
        _args = [
          "SUPER + Q"
          (lib.generators.mkLuaInline "hl.dsp.window.close()")
        ];
      }
      {
        _args = [
          "SUPER + P"
          (lib.generators.mkLuaInline "hl.dsp.window.pseudo()")
        ];
      }
      {
        _args = [
          "SUPER + F"
          (lib.generators.mkLuaInline "hl.dsp.window.fullscreen()")
        ];
      }
      {
        _args = [
          "SUPER + SHIFT + F"
          (lib.generators.mkLuaInline "hl.dsp.window.float({ action = \"toggle\" })")
        ];
      }
      {
        _args = [
          "SUPER + SHIFT + left"
          (lib.generators.mkLuaInline "hl.dsp.window.move({ direction = \"left\" })")
        ];
      }
      {
        _args = [
          "SUPER + SHIFT + right"
          (lib.generators.mkLuaInline "hl.dsp.window.move({ direction = \"right\" })")
        ];
      }
      {
        _args = [
          "SUPER + SHIFT + up"
          (lib.generators.mkLuaInline "hl.dsp.window.move({ direction = \"up\" })")
        ];
      }
      {
        _args = [
          "SUPER + SHIFT + down"
          (lib.generators.mkLuaInline "hl.dsp.window.move({ direction = \"down\" })")
        ];
      }
      {
        _args = [
          "SUPER + SHIFT + h"
          (lib.generators.mkLuaInline "hl.dsp.window.move({ direction = \"left\" })")
        ];
      }
      {
        _args = [
          "SUPER + SHIFT + l"
          (lib.generators.mkLuaInline "hl.dsp.window.move({ direction = \"right\" })")
        ];
      }
      {
        _args = [
          "SUPER + SHIFT + k"
          (lib.generators.mkLuaInline "hl.dsp.window.move({ direction = \"up\" })")
        ];
      }
      {
        _args = [
          "SUPER + SHIFT + j"
          (lib.generators.mkLuaInline "hl.dsp.window.move({ direction = \"down\" })")
        ];
      }
      {
        _args = [
          "SUPER + ALT + left"
          (lib.generators.mkLuaInline "hl.dsp.layout(\"swapwindow\", { direction = \"left\" })")
        ];
      }
      {
        _args = [
          "SUPER + ALT + right"
          (lib.generators.mkLuaInline "hl.dsp.layout(\"swapwindow\", { direction = \"right\" })")
        ];
      }
      {
        _args = [
          "SUPER + ALT + up"
          (lib.generators.mkLuaInline "hl.dsp.layout(\"swapwindow\", { direction = \"up\" })")
        ];
      }
      {
        _args = [
          "SUPER + ALT + down"
          (lib.generators.mkLuaInline "hl.dsp.layout(\"swapwindow\", { direction = \"down\" })")
        ];
      }
      {
        _args = [
          "SUPER + ALT + code:43"
          (lib.generators.mkLuaInline "hl.dsp.layout(\"swapwindow\", { direction = \"left\" })")
        ];
      }
      {
        _args = [
          "SUPER + ALT + code:46"
          (lib.generators.mkLuaInline "hl.dsp.layout(\"swapwindow\", { direction = \"right\" })")
        ];
      }
      {
        _args = [
          "SUPER + ALT + code:45"
          (lib.generators.mkLuaInline "hl.dsp.layout(\"swapwindow\", { direction = \"up\" })")
        ];
      }
      {
        _args = [
          "SUPER + ALT + code:44"
          (lib.generators.mkLuaInline "hl.dsp.layout(\"swapwindow\", { direction = \"down\" })")
        ];
      }
      {
        _args = [
          "SUPER + left"
          (lib.generators.mkLuaInline "hl.dsp.focus({ direction = \"left\" })")
        ];
      }
      {
        _args = [
          "SUPER + right"
          (lib.generators.mkLuaInline "hl.dsp.focus({ direction = \"right\" })")
        ];
      }
      {
        _args = [
          "SUPER + up"
          (lib.generators.mkLuaInline "hl.dsp.focus({ direction = \"up\" })")
        ];
      }
      {
        _args = [
          "SUPER + down"
          (lib.generators.mkLuaInline "hl.dsp.focus({ direction = \"down\" })")
        ];
      }
      {
        _args = [
          "SUPER + h"
          (lib.generators.mkLuaInline "hl.dsp.focus({ direction = \"left\" })")
        ];
      }
      {
        _args = [
          "SUPER + l"
          (lib.generators.mkLuaInline "hl.dsp.focus({ direction = \"right\" })")
        ];
      }
      {
        _args = [
          "SUPER + k"
          (lib.generators.mkLuaInline "hl.dsp.focus({ direction = \"up\" })")
        ];
      }
      {
        _args = [
          "SUPER + j"
          (lib.generators.mkLuaInline "hl.dsp.focus({ direction = \"down\" })")
        ];
      }
      {
        _args = [
          "SUPER + 1"
          (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = 1 })")
        ];
      }
      {
        _args = [
          "SUPER + 2"
          (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = 2 })")
        ];
      }
      {
        _args = [
          "SUPER + 3"
          (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = 3 })")
        ];
      }
      {
        _args = [
          "SUPER + 4"
          (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = 4 })")
        ];
      }
      {
        _args = [
          "SUPER + 5"
          (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = 5 })")
        ];
      }
      {
        _args = [
          "SUPER + 6"
          (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = 6 })")
        ];
      }
      {
        _args = [
          "SUPER + 7"
          (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = 7 })")
        ];
      }
      {
        _args = [
          "SUPER + 8"
          (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = 8 })")
        ];
      }
      {
        _args = [
          "SUPER + 9"
          (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = 9 })")
        ];
      }
      {
        _args = [
          "SUPER + 0"
          (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = 10 })")
        ];
      }
      {
        _args = [
          "SUPER + SHIFT + SPACE"
          (lib.generators.mkLuaInline "hl.dsp.window.move({ workspace = \"special\" })")
        ];
      }
      {
        _args = [
          "SUPER + SPACE"
          (lib.generators.mkLuaInline "hl.dsp.workspace.toggle_special()")
        ];
      }
      {
        _args = [
          "SUPER + SHIFT + 1"
          (lib.generators.mkLuaInline "hl.dsp.window.move({ workspace = 1 })")
        ];
      }
      {
        _args = [
          "SUPER + SHIFT + 2"
          (lib.generators.mkLuaInline "hl.dsp.window.move({ workspace = 2 })")
        ];
      }
      {
        _args = [
          "SUPER + SHIFT + 3"
          (lib.generators.mkLuaInline "hl.dsp.window.move({ workspace = 3 })")
        ];
      }
      {
        _args = [
          "SUPER + SHIFT + 4"
          (lib.generators.mkLuaInline "hl.dsp.window.move({ workspace = 4 })")
        ];
      }
      {
        _args = [
          "SUPER + SHIFT + 5"
          (lib.generators.mkLuaInline "hl.dsp.window.move({ workspace = 5 })")
        ];
      }
      {
        _args = [
          "SUPER + SHIFT + 6"
          (lib.generators.mkLuaInline "hl.dsp.window.move({ workspace = 6 })")
        ];
      }
      {
        _args = [
          "SUPER + SHIFT + 7"
          (lib.generators.mkLuaInline "hl.dsp.window.move({ workspace = 7 })")
        ];
      }
      {
        _args = [
          "SUPER + SHIFT + 8"
          (lib.generators.mkLuaInline "hl.dsp.window.move({ workspace = 8 })")
        ];
      }
      {
        _args = [
          "SUPER + SHIFT + 9"
          (lib.generators.mkLuaInline "hl.dsp.window.move({ workspace = 9 })")
        ];
      }
      {
        _args = [
          "SUPER + SHIFT + 0"
          (lib.generators.mkLuaInline "hl.dsp.window.move({ workspace = 10 })")
        ];
      }
      {
        _args = [
          "SUPER + CONTROL + right"
          (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = \"e+1\" })")
        ];
      }
      {
        _args = [
          "SUPER + CONTROL + left"
          (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = \"e-1\" })")
        ];
      }
      {
        _args = [
          "SUPER + mouse_down"
          (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = \"e+1\" })")
        ];
      }
      {
        _args = [
          "SUPER + mouse_up"
          (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = \"e-1\" })")
        ];
      }
      {
        _args = [
          "ALT + Tab"
          (lib.generators.mkLuaInline "hl.dsp.layout(\"cyclenext\")")
        ];
      }
      {
        _args = [
          "XF86AudioPlay"
          (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"playerctl play-pause\")")
          { locked = true; }
        ];
      }
      {
        _args = [
          "XF86AudioPause"
          (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"playerctl play-pause\")")
          { locked = true; }
        ];
      }
      {
        _args = [
          "XF86AudioNext"
          (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"playerctl next\")")
          { locked = true; }
        ];
      }
      {
        _args = [
          "XF86AudioPrev"
          (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"playerctl previous\")")
          { locked = true; }
        ];
      }
      {
        _args = [
          "XF86AudioRaiseVolume"
          (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"swayosd-client --output-volume raise\")")
          {
            locked = true;
            repeating = true;
          }
        ];
      }
      {
        _args = [
          "XF86AudioLowerVolume"
          (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"swayosd-client --output-volume lower\")")
          {
            locked = true;
            repeating = true;
          }
        ];
      }
      {
        _args = [
          "XF86AudioMute"
          (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"swayosd-client --output-volume mute-toggle\")")
          {
            locked = true;
            repeating = true;
          }
        ];
      }
      {
        _args = [
          "XF86MonBrightnessUp"
          (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"swayosd-client --brightness raise\")")
          {
            locked = true;
            repeating = true;
          }
        ];
      }
      {
        _args = [
          "XF86MonBrightnessDown"
          (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"swayosd-client --brightness lower\")")
          {
            locked = true;
            repeating = true;
          }
        ];
      }
      {
        _args = [
          "F8"
          (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"nwg-displays\")")
        ];
      }
      {
        _args = [
          "SUPER + mouse:272"
          (lib.generators.mkLuaInline "hl.dsp.window.drag()")
          { mouse = true; }
        ];
      }
      {
        _args = [
          "SUPER + mouse:273"
          (lib.generators.mkLuaInline "hl.dsp.window.resize()")
          { mouse = true; }
        ];
      }
      {
        _args = [
          "SUPER + SUPER_L"
          (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"pkill rofi || rofi -show drun\")")
          { release = true; }
        ];
      }
    ];
  };
}
