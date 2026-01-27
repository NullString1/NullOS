{ ... }:
{
  services.ollama = {
    enable = true;
    openFirewall = true;
    loadModels = [ "gemma3:4b" ];
  };
}
