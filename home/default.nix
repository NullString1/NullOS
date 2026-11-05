{
  pkgs,
  vars,
  lib,
  ...
}:
let
  inherit (lib) optionals;
  inherit (vars) isHyprland isKDE;
in
{
  home.packages = optionals isHyprland [
    (import ./scripts/screenshotin.nix { inherit pkgs; })
    (import ./scripts/screenshot-ocr.nix { inherit pkgs; })
    (import ./scripts/wallsetter.nix { inherit pkgs; })
    pkgs.tesseract
    pkgs.papirus-icon-theme
    pkgs.bibata-cursors
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.font-awesome
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
    ./tealdeer.nix
    ./ssh.nix
    ./fzf.nix
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
  ++ optionals (vars.enableAntigravityCLI) [ ./antigravity.nix ]
  ++ optionals (vars.enableLibreOffice) [ ./libreoffice.nix ]
  ++ optionals (vars.enableOpencode) [ ./opencode.nix ]
  ++ optionals (vars.enableWayVNC) [ ./wayvnc.nix ]
  ++ optionals (vars.enableKDEConnect) [ ./kdeconnect.nix ];

  # Catppuccin Mocha configuration
  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = "mocha";
    accent = "mauve";
    hyprland.enable = false;
    hyprlock.enable = false;
    waybar.enable = false;
    swaync.enable = true;
    wlogout.enable = true;
    starship.enable = true;
    yazi.enable = false;
    cache.enable = true;
    sources = inputs.catppuccin.packages.${pkgs.stdenv.hostPlatform.system}.overrideScope (
      _: _: {
        whiskers = pkgs.catppuccin-whiskers;
      }
    );
  };

  services.blueman-applet.enable = true;
}
