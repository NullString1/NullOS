{ pkgs }:
pkgs.writeShellScriptBin "screenshotin" ''
  set -euo pipefail

  # Freeze screen so tooltips and dropdowns don't dismiss during selection
  ${pkgs.hyprpicker}/bin/hyprpicker -r -z >/dev/null 2>&1 &
  FREEZE_PID=$!
  sleep 0.05

  SELECTION=$(${pkgs.slurp}/bin/slurp 2>/dev/null) || true
  kill $FREEZE_PID 2>/dev/null || true

  if [[ -n "''${SELECTION:-}" ]]; then
    ${pkgs.grim}/bin/grim -g "$SELECTION" - | ${pkgs.swappy}/bin/swappy -f -
  fi
''
