{ vars, ... }:
{
  wayland.windowManager.hyprland.settings = {
    env = [
      {
        _args = [
          "NIXOS_OZONE_WL"
          "1"
        ];
      }
      {
        _args = [
          "NIXPKGS_ALLOW_UNFREE"
          "1"
        ];
      }
      {
        _args = [
          "XDG_CURRENT_DESKTOP"
          "Hyprland"
        ];
      }
      {
        _args = [
          "XDG_SESSION_TYPE"
          "wayland"
        ];
      }
      {
        _args = [
          "XDG_SESSION_DESKTOP"
          "Hyprland"
        ];
      }
      {
        _args = [
          "GDK_BACKEND"
          "wayland,x11"
        ];
      }
      {
        _args = [
          "CLUTTER_BACKEND"
          "wayland"
        ];
      }
      {
        _args = [
          "QT_QPA_PLATFORM"
          "wayland;xcb"
        ];
      }
      {
        _args = [
          "QT_WAYLAND_DISABLE_WINDOWDECORATION"
          "1"
        ];
      }
      {
        _args = [
          "QT_AUTO_SCREEN_SCALE_FACTOR"
          "1"
        ];
      }
      {
        _args = [
          "SDL_VIDEODRIVER"
          "x11"
        ];
      }
      {
        _args = [
          "MOZ_ENABLE_WAYLAND"
          "1"
        ];
      }
      {
        _args = [
          "AQ_DRM_DEVICES"
          "/dev/dri/card1:/dev/dri/card2"
        ];
      }
      {
        _args = [
          "GDK_SCALE"
          "1"
        ];
      }
      {
        _args = [
          "QT_SCALE_FACTOR"
          "1"
        ];
      }
      {
        _args = [
          "EDITOR"
          "nvim"
        ];
      }
      {
        _args = [
          "TERMINAL"
          "${vars.terminal}"
        ];
      }
      {
        _args = [
          "XDG_TERMINAL_EMULATOR"
          "${vars.terminal}"
        ];
      }
    ];
  };
}
