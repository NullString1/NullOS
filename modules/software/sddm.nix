{
  pkgs,
  vars,
  ...
}:
{
  environment.systemPackages = pkgs.lib.mkIf (vars.isHyprland || vars.isKDE) [ pkgs.sddm-astronaut ];
  services.displayManager =
    if vars.isHyprland || vars.isKDE then
      {
        enable = true;
        defaultSession =
          if vars.isHyprland then
            "hyprland"
          else if vars.isKDE then
            "plasma"
          else
            null;
        sddm = {
          enable = true;
          wayland.enable = true;
          theme = "sddm-astronaut-theme";
          package = pkgs.kdePackages.sddm;
          extraPackages = [ pkgs.kdePackages.qtmultimedia ];
        };
      }
    else
      {
        enable = false;
      };
}
