{
  pkgs,
  vars,
  ...
}:
let
  isHyprland = vars.desktopEnvironment == "hyprland";
  isKde = vars.desktopEnvironment == "kde";
in
{
  environment.systemPackages = [ pkgs.sddm-astronaut ];
  services.displayManager.sddm = {
    enable = vars.desktopEnvironment != null;
    wayland.enable = true;
    theme = "sddm-astronaut-theme";
    package = pkgs.kdePackages.sddm;
    extraPackages = [ pkgs.kdePackages.qtmultimedia ];
  };
  services.displayManager.defaultSession =
    if isHyprland then
      "hyprland"
    else if isKde then
      "plasma"
    else
      null;
}
