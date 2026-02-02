{ inputs, vars, lib, ... }:
let 
  inherit (lib) optionals;
in
{
  imports = [
    ./packages.nix
    ./starship.nix
    ./nh.nix
    ./sddm.nix
    ./dolphin.nix
    ./devtools.nix
    inputs.stylix.nixosModules.stylix
  ]
  ++ optionals (vars.enableAndroid) [ ./android-studio.nix ]
  ++ optionals (vars.enableSteam) [ ./steam.nix ]
  ++ optionals (vars.enableFlatpak) [ ./flatpak.nix ]
  ++ optionals (vars.enableDBGate) [ ./dbgate.nix ];
}
