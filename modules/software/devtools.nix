{ pkgs, vars, ... }:
{
  environment.systemPackages = [

  ]
  ++ (if vars.enableDBGate then [ pkgs.dbgate ] else [ ])
  ++ (
    if vars.enableDevMisc then
      with pkgs;
      [
        p7zip
        binwalk
        hexdump
        unrar
        unzip
        waypipe # For Running Wayland Apps Over SSH
        cachix # Cachix Client
        nixfmt # Nix Formatter
      ]
    else
      [ ]
  );
}
