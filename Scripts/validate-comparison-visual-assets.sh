#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ASSET="$ROOT_DIR/Documentation/Assets/Comparisons/swiftintelligence-comparisons-board.svg"
PAGE="$ROOT_DIR/Documentation/Comparisons/README.md"
TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

[[ -f "$ASSET" ]] || {
  echo "Missing comparison visual asset: $ASSET" >&2
  exit 1
}

xmllint --noout "$ASSET"

grep -q 'viewBox="' "$ASSET" || {
  echo "Missing viewBox in comparison visual asset." >&2
  exit 1
}

grep -q 'preserveAspectRatio="xMidYMid meet"' "$ASSET" || {
  echo "Missing preserveAspectRatio contract in comparison visual asset." >&2
  exit 1
}

grep -q 'font-family=' "$ASSET" || {
  echo "Missing font-family declaration in comparison visual asset." >&2
  exit 1
}

RASTERIZED_ASSET="$TMP_DIR/comparisons-board.png"
sips -s format png "$ASSET" --out "$RASTERIZED_ASSET" >/dev/null

actual_width="$(sips -g pixelWidth "$RASTERIZED_ASSET" | awk '/pixelWidth/ {print $2}')"
actual_height="$(sips -g pixelHeight "$RASTERIZED_ASSET" | awk '/pixelHeight/ {print $2}')"

[[ "$actual_width" == "1400" ]] || {
  echo "Unexpected comparison board width: $actual_width" >&2
  exit 1
}

[[ "$actual_height" == "900" ]] || {
  echo "Unexpected comparison board height: $actual_height" >&2
  exit 1
}

grep -q 'swiftintelligence-comparisons-board.svg' "$PAGE" || {
  echo "Documentation/Comparisons/README.md must reference swiftintelligence-comparisons-board.svg." >&2
  exit 1
}

echo "Comparison visual assets validated."
