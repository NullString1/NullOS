{ pkgs }:
pkgs.writeShellScriptBin "screenshotin" ''
  grim -g "$(slurp)" - | swappy -f -
''
