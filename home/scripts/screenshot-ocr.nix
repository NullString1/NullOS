{ pkgs }:
pkgs.writeShellScriptBin "screenshot-ocr" ''
  set -euo pipefail

  TEMP_DIR=$(mktemp -d)
  RAW_PNG="$TEMP_DIR/raw.png"
  PREP_PNG="$TEMP_DIR/prep.png"
  trap "rm -rf '$TEMP_DIR'" EXIT

  # 1. Freeze screen so tooltips and animations don't shift during selection
  ${pkgs.hyprpicker}/bin/hyprpicker -r -z >/dev/null 2>&1 &
  FREEZE_PID=$!
  sleep 0.05

  # 2. Select region
  SELECTION=$(${pkgs.slurp}/bin/slurp 2>/dev/null) || true
  kill $FREEZE_PID 2>/dev/null || true

  if [[ -z "''${SELECTION:-}" ]]; then
    exit 0
  fi

  # 3. Capture raw cropped image
  ${pkgs.grim}/bin/grim -g "$SELECTION" "$RAW_PNG"

  # 4. ImageMagick Preprocessing:
  #    - Check if background is dark; if so, invert to dark-text on white
  #    - Upscale 2.5x to bring UI font sizes up to print-grade resolution (prevents noise interpretation)
  #    - Add border padding so edge characters are not clipped by Leptonica
  #    - Contrast stretch for crisp edges
  ${pkgs.imagemagick}/bin/magick "$RAW_PNG" \
    -colorspace Gray \
    -format "%[fx:mean<0.5?1:0]" info: > "$TEMP_DIR/is_dark.txt"

  IS_DARK=$(cat "$TEMP_DIR/is_dark.txt")
  declare -a CONVERT_OPTS=()
  if [[ "$IS_DARK" -eq 1 ]]; then
    CONVERT_OPTS+=("-negate")
  fi

  ${pkgs.imagemagick}/bin/magick "$RAW_PNG" \
    -colorspace Gray \
    "''${CONVERT_OPTS[@]}" \
    -filter Lanczos -resize 250% \
    -contrast-stretch 0.1%x0.1% \
    -bordercolor white -border 12 \
    "$PREP_PNG"

  # 5. Run Tesseract with:
  #    - LSTM neural net engine (--oem 1)
  #    - Uniform text block segmentation (--psm 6)
  #    - 300 DPI scaling
  #    - Preserve indentation/spaces (-c preserve_interword_spaces=1)
  TEXT=$(${pkgs.tesseract}/bin/tesseract "$PREP_PNG" stdout \
    --oem 1 \
    --psm 6 \
    --dpi 300 \
    -c preserve_interword_spaces=1 2>/dev/null) || true

  # 6. Fallback to sparse text (--psm 11) if PSM 6 yielded empty output
  if [[ -z "''${TEXT//[[:space:]]/}" ]]; then
    TEXT=$(${pkgs.tesseract}/bin/tesseract "$PREP_PNG" stdout \
      --oem 1 \
      --psm 11 \
      --dpi 300 \
      -c preserve_interword_spaces=1 2>/dev/null) || true
  fi

  if [[ -n "''${TEXT//[[:space:]]/}" ]]; then
    printf "%s" "$TEXT" | ${pkgs.wl-clipboard}/bin/wl-copy
    ${pkgs.libnotify}/bin/notify-send -t 3500 "OCR Text Copied" "$TEXT"
  else
    ${pkgs.libnotify}/bin/notify-send -u low -t 2000 "OCR" "No text recognized"
  fi
''
