{ pkgs, vars, ... }:
{
  # Environment variables for KDE Plasma Wayland session
  # KDE sets XDG_CURRENT_DESKTOP, XDG_SESSION_TYPE, QT_QPA_PLATFORM, etc. natively
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    NIXPKGS_ALLOW_UNFREE = "1";
    MOZ_ENABLE_WAYLAND = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    SDL_VIDEODRIVER = "x11";
    EDITOR = "nvim";
    TERMINAL = vars.terminal;
    XDG_TERMINAL_EMULATOR = vars.terminal;
  };

  # Additional KDE/Plasma utilities not bundled by default
  home.packages = with pkgs.kdePackages; [
    kate # Text editor
    kcalc # Calculator
    ark # Archive manager
    spectacle # Screenshot tool
    filelight # Disk usage visualiser
    plasma-browser-integration # Browser integration
    kdeplasma-addons # Extra Plasma widgets
    kscreen # Display management
    sddm-kcm # SDDM login screen settings module
  ];
}
