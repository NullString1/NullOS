{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    wineWow64Packages.waylandFull
    winetricks
  ];
  boot.binfmt.registrations.wine = {
    interpreter = "${pkgs.wineWow64Packages.waylandFull}/bin/wine";
    magicOrExtension = "MZ";
    offset = 0;
    mask = "";
    recognitionType = "magic";
  };
}
