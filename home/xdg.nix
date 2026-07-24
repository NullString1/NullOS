{ pkgs, vars, ... }:
let
  inherit (vars) isHyprland isKDE isHeadless;
in
{
  xdg = {
    enable = true;
    mime.enable = true;
    portal = {
      enable = !isHeadless;
      extraPortals =
        if isHyprland then
          [
            pkgs.xdg-desktop-portal-hyprland
            pkgs.kdePackages.xdg-desktop-portal-kde
          ]
        else if isKDE then
          [ pkgs.kdePackages.xdg-desktop-portal-kde ]
        else
          [ ];
      configPackages =
        if isHyprland then
          [ pkgs.hyprland ]
        else if isKDE then
          [ pkgs.kdePackages.plasma-workspace ]
        else
          [ ];
      config = {
        common = {
          default =
            if isHyprland then
              [
                "hyprland"
                "kde"
              ]
            else if isKDE then
              [ "kde" ]
            else
              [ ];
          "org.freedesktop.impl.portal.FileChooser" = if isHeadless then null else "kde";
        };
      };
    };
  };
}
