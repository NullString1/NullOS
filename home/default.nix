{
  pkgs,
  vars,
  lib,
  ...
}:
let
  inherit (lib) optionals;
  isHyprland = vars.desktopEnvironment == "hyprland";
  isKDE = vars.desktopEnvironment == "kde";
in
{
  home.packages = optionals isHyprland [
    (import ./scripts/screenshotin.nix { inherit pkgs; })
    (import ./scripts/keybinds.nix { inherit pkgs; })
    (import ./scripts/rofi-launcher.nix { inherit pkgs; })
    (import ./scripts/wallsetter.nix { inherit pkgs; })
  ];

  imports = [
    # DE-agnostic modules
    ./fastfetch
    ./yazi
    ./zsh
    ./starship.nix
    ./gtk.nix
    ./xdg.nix
    ./ghostty.nix
    ./eza.nix
    ./bottom.nix
    ./bat.nix
    ./qt.nix
    ./zoxide.nix
    ./stylix.nix
    ./tealdeer.nix
  ]
  # Hyprland-specific modules
  ++ optionals isHyprland [
    ./swayosd.nix
    ./nwg-displays.nix
    ./hyprland
    ./rofi
    ./waybar
    ./wlogout
    ./swaync.nix
    ./swappy.nix
  ]
  # KDE-specific modules
  ++ optionals isKDE [
    ./kde.nix
  ]
  # Optional feature modules
  ++ optionals (vars.enableNVIM) [ ./nixvim.nix ]
  ++ optionals (vars.enableVSCode) [ ./vscode.nix ]
  ++ optionals (vars.enableGit) [ ./git.nix ]
  ++ optionals (vars.enableFusion360) [ ./fusion360.nix ]
  ++ optionals (vars.enableLutris) [ ./lutris.nix ]
  ++ optionals (vars.enableDevMisc) [ ./httpie-desktop.nix ]
  ++ optionals (vars.enableBottles) [ ./bottles.nix ]
  ++ optionals (vars.enableLibreOffice) [ ./libreoffice.nix ]
  ++ optionals (vars.enableOpencode) [ ./opencode.nix ];
}
