{ pkgs, ... }:
{
  home.packages = with pkgs; [ libreoffice-fresh ];

  xdg.dataFile = {
    "applications/calc.desktop".source = "${pkgs.libreoffice-fresh}/share/applications/calc.desktop";
    "applications/writer.desktop".source =
      "${pkgs.libreoffice-fresh}/share/applications/writer.desktop";
    "applications/impress.desktop".source =
      "${pkgs.libreoffice-fresh}/share/applications/impress.desktop";
    "applications/draw.desktop".source = "${pkgs.libreoffice-fresh}/share/applications/draw.desktop";
    "applications/base.desktop".source = "${pkgs.libreoffice-fresh}/share/applications/base.desktop";
    "applications/math.desktop".source = "${pkgs.libreoffice-fresh}/share/applications/math.desktop";
  };
}
