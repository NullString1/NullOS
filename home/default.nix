{ pkgs, vars, ... }:
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
    #./kde.nix
    ./xdg.nix
    ./ghostty.nix
    ./swaync.nix
    #./nvf.nix
    ./eza.nix
    ./bottom.nix
    ./bat.nix
    ./qt.nix
    ./zoxide.nix
    ./stylix.nix
    ./tealdeer.nix
    ./swappy.nix
  ]
  ++ (if vars.enableNVIM then [ ./nixvim.nix ] else [ ])
  ++ (if vars.enableVSCode then [ ./vscode.nix ] else [ ])
  ++ (if vars.enableGit then [ ./git.nix ] else [ ])
  ++ (if vars.enableFusion360 then [ ./fusion360.nix ] else [ ])
  ++ (if vars.enableLutris then [ ./lutris.nix ] else [ ])
  ++ (if vars.enableDevMisc then [ ./httpie-desktop.nix ] else [ ])
  ++ (if vars.enableBottles then [ ./bottles.nix ] else [ ])
  ++ (if vars.enableLibreOffice then [ ./libreoffice.nix ] else [ ]);
}
