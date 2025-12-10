{ inputs, ... }:
{
  imports = [
    ./packages.nix
    ./starship.nix
    ./nh.nix
    ./sddm.nix
    ./dolphin.nix
    ./flatpak.nix
    ./steam.nix
    ./android-studio.nix
    inputs.stylix.nixosModules.stylix
  ];
}
