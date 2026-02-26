{ pkgs }:
pkgs.writeShellScriptBin "screenshot-ocr" ''
  set -e

  TEMP_DIR=$(mktemp -d)
  IMAGE_FILE="$TEMP_DIR/screenshot.png"
  TEXT_FILE="$TEMP_DIR/output.txt"

  trap "rm -rf $TEMP_DIR" EXIT

  # Take screenshot of selected area
  grim -g "$(slurp)" "$IMAGE_FILE"

  # Run OCR with tesseract
  tesseract "$IMAGE_FILE" "$TEXT_FILE"

  # Copy to clipboard
  cat "$TEXT_FILE.txt" | wl-copy

  echo "OCR text copied to clipboard"
''
