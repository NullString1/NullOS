{ vars, lib, ... }:
let
  inherit (lib) optionals;
in
{
  imports = [
    ./services.nix
    ./virtualisation.nix
    ./vpn.nix
    ./xserver.nix
    ./sunshine.nix
  ]
  ++ optionals vars.enableLlamaCpp [ ./llamacpp.nix ]
  ++ optionals vars.enableResticBackup [ ./backup.nix ]
  ++ optionals vars.enableMinecraft [ ./minecraft.nix ]
  ++ optionals vars.enableNextDNS [ ./nextdns.nix ]
  ++ optionals vars.enableKDEConnect [ ./kdeconnect.nix ];
}
