{ pkgs, ... }:
{
    services.ollama = {
        enable = true;
        openFirewall = true;
        loadModels = [ "gemma3:4b" ];
        package = pkgs.ollama-cuda;
    };
}