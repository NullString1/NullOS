{
  pkgs,
  inputs,
  ...
}:
let
  sunshine = inputs.nixpkgs-stable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.sunshine;
in
{
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
    package = sunshine;
  };
}
