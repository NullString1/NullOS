{ pkgs, ... }:

{
  home.packages = [ pkgs.wleave ];
  xdg.configFile."wleave.css".source = ../wleave.css;
}