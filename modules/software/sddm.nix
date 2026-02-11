{
  pkgs,
  vars,
  ...
}:
let
  isHyprland = vars.desktopEnvironment == "hyprland";
in
{
  environment.systemPackages = [ pkgs.sddm-astronaut ];
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "sddm-astronaut-theme";
    package = pkgs.kdePackages.sddm;
    extraPackages = [ pkgs.kdePackages.qtmultimedia ];
  };
  services.displayManager.defaultSession = if isHyprland then "hyprland" else "plasma";
}
