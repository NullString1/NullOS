{
  lib,
  pkgs,
  vars,
  ...
}:
let
  isKDE = vars.desktopEnvironment == "kde";
in
{
  qt = {
    enable = true;
    platformTheme.name = lib.mkForce (if isKDE then "kde" else "kvantum");
    style.name = lib.mkForce "kvantum";
    # xdg-desktop-portal-kde dialogs (e.g. the "wants to open" app chooser)
    # read their icon theme from kdeglobals, not from GTK. Without this they
    # fall back to Breeze/hicolor and icons render dark-on-dark under our
    # dark Kvantum style. Match the GTK icon theme (see ./gtk.nix).
    kde.settings = lib.mkIf (!isKDE) {
      kdeglobals.Icons.Theme = "Papirus-Dark";
    };
  };

  # Fallback icons for KDE dialogs when Papirus lacks a name.
  home.packages = lib.optionals (!isKDE) [ pkgs.kdePackages.breeze-icons ];
}
