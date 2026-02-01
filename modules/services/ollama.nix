{ pkgs, vars, ... }:
{
  services.ollama = {
    enable = true;
    openFirewall = true;
    loadModels = [ "qwen3-instruct:4b" ];
    host = if vars.enableExposeOllama then "[::]" else "127.0.0.1";
    package = if vars.useNvidia then pkgs.ollama-cuda else pkgs.ollama-cpu;
  };
}
