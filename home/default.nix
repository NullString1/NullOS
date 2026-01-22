{ pkgs, ... }:
{
  home.packages = [
    (import ./scripts/screenshotin.nix { inherit pkgs; })
    (import ./scripts/keybinds.nix { inherit pkgs; })
    (import ./scripts/rofi-launcher.nix { inherit pkgs; })
    (import ./scripts/wallsetter.nix { inherit pkgs; })
  ];
  imports = [
    ./fusion360.nix
    ./lutris.nix
    ./httpie-desktop.nix
    ./office.nix
    ./swayosd.nix
    ./nwg-displays.nix
    ./nixvim.nix
    #./bottles.nix
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
    ./git.nix
    ./vscode.nix
    ./tealdeer.nix
    ./gh.nix
    ./swappy.nix
  ];
}
