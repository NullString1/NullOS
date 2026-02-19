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
  ++ optionals vars.enableOllama [ ./ollama.nix ]
  ++ optionals vars.enableResticBackup [ ./backup.nix ]
  ++ optionals vars.enableMinecraft [ ./minecraft.nix ];
}
