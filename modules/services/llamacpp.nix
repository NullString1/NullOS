{ vars, pkgs, ... }:
let 
  inherit (vars) enableExposeLlamaCpp;
in
{
  services.llama-cpp = {
    enable = true;
    openFirewall = true;
    settings = {
      host = if enableExposeLlamaCpp then "0.0.0.0" else "127.0.0.1";
      hf-repo = "empero-ai/Qwythos-9B-Claude-Mythos-5-1M-GGUF";
      hf-file = "Qwythos-9B-Claude-Mythos-5-1M-MTP-Q4_K_M.gguf";
      alias = "qwthos";
      flash-attn = "on";
      cache-type-k = "q4_0";
      cache-type-v = "q4_0";
      ctx-size = 8192;
      parallel = 1;
      temp = 0.6;
      top-p = 0.95;
      top-k = 20;
      repeat-penalty = 1.05;
      gpu-layers = 99;
      no-mmproj = "";
    };
    package = (pkgs.llama-cpp.override {
      cudaSupport = true;
      blasSupport = true;
      rocmSupport = false;
      metalSupport = false;
    }).overrideAttrs (oldAttrs: {
      cmakeFlags = (oldAttrs.cmakeFlags or []) ++ [
        "-DGGML_NATIVE=ON"
      ];
      preConfigure = ''
        export NIX_ENFORCE_NO_NATIVE=0
        ${oldAttrs.preConfigure or ""}
      '';
    });
  };
}
