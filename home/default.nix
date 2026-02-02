{ pkgs, vars, lib, ... }:
let 
  inherit (lib) optionals;
in
{
  home.packages = [
    (import ./scripts/screenshotin.nix { inherit pkgs; })
    (import ./scripts/keybinds.nix { inherit pkgs; })
    (import ./scripts/rofi-launcher.nix { inherit pkgs; })
    (import ./scripts/wallsetter.nix { inherit pkgs; })
  ];

  imports = [
    ./swayosd.nix
    ./nwg-displays.nix
    ./fastfetch
    ./hyprland
    ./rofi
    ./waybar
    ./wlogout
    ./yazi
    ./zsh
    ./starship.nix
    ./gtk.nix
    ./xdg.nix
    ./ghostty.nix
    ./swaync.nix
    ./eza.nix
    ./bottom.nix
    ./bat.nix
    ./qt.nix
    ./zoxide.nix
    ./stylix.nix
    ./tealdeer.nix
    ./swappy.nix
  ]
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
