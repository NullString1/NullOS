{
  pkgs,
  inputs,
  ...
}:
let
  sunshine = inputs.nixpkgs-stable.legacyPackages.${pkgs.system}.sunshine;
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
