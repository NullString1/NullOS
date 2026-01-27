{ vars, ... }:
{
  imports = [
    ./backup.nix
    ./services.nix
    ./virtualisation.nix
    ./vpn.nix
    ./xserver.nix
    ./sunshine.nix
  ]
  ++ (if vars.enableOllama then [ ./ollama.nix ] else [ ])
  ++ (if vars.enableResticBackup then [ ./backup.nix ] else [ ]);
}
