{ pkgs, vars, ... }:
let
  isHyprland = vars.desktopEnvironment == "hyprland";
  isKDE = vars.desktopEnvironment == "kde";
in
{
  xdg.portal = {
    enable = true;
    extraPortals =
      if isHyprland then
        [ pkgs.xdg-desktop-portal-hyprland ]
      else if isKDE then
        [ pkgs.xdg-desktop-portal-kde ]
      else
        [ ];
    configPackages =
      if isHyprland then
        [ pkgs.hyprland ]
      else if isKDE then
        [ pkgs.kdePackages.plasma-workspace ]
      else
        [ ];
  };
  services = {
    flatpak.enable = true;
  };
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };
}
