{ inputs, vars, ... }:
{
  imports = [
    ./packages.nix
    ./starship.nix
    ./nh.nix
    ./sddm.nix
    ./dolphin.nix
    inputs.stylix.nixosModules.stylix
  ]
  ++ (if vars.enableAndroid then [ ./android-studio.nix ] else [ ])
  ++ (if vars.enableSteam then [ ./steam.nix ] else [ ])
  ++ (if vars.enableFlatpak then [ ./flatpak.nix ] else [ ])
  ++ (if vars.enableDBGate then [ ./dbgate.nix ] else [ ]);
}
