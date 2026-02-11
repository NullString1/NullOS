{ lib, vars, ... }:
let
  isKDE = vars.desktopEnvironment == "kde";
in
{
  qt = {
    enable = true;
    # KDE manages its own Qt theming natively; Kvantum is needed for standalone WMs like Hyprland
    platformTheme.name = lib.mkForce (if isKDE then "kde" else "kvantum");
  };
}
