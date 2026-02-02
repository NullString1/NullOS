{ pkgs, vars, lib, ... }:
{
  environment.systemPackages = lib.optionals vars.enableDBGate [ pkgs.dbgate ]
    ++ lib.optionals vars.enableDevMisc [
      pkgs.p7zip
      pkgs.binwalk
      pkgs.hexdump
      pkgs.unrar
      pkgs.unzip
      pkgs.waypipe # For Running Wayland Apps Over SSH
      pkgs.cachix # Cachix Client
      pkgs.nixfmt # Nix Formatter
    ];
}
