{
  pkgs,
  vars,
  ...
}:
{
  environment.systemPackages = [ pkgs.sddm-astronaut ];
  services.displayManager =
    if !vars.isHeadless then
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
          enable = !vars.isHeadless;
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
