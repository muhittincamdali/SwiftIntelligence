#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ASSET="$ROOT_DIR/Documentation/Assets/Docs/swiftintelligence-docs-board.svg"
BASELINE_ASSET="$ROOT_DIR/Documentation/Assets/Docs/Baselines/swiftintelligence-docs-board.png"
PAGE="$ROOT_DIR/Documentation/README.md"
TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

render_svg_snapshot() {
  local source_asset="$1"
  local raster_width="$2"
  local output_asset="$3"
  local temp_snapshot

  rm -f "$output_asset"
  qlmanage -t -s "$raster_width" -o "$TMP_DIR" "$source_asset" >/dev/null
  temp_snapshot="$TMP_DIR/$(basename "$source_asset").png"

  [[ -f "$temp_snapshot" ]] || {
    echo "Quick Look rasterization failed for $source_asset" >&2
    exit 1
  }

  mv "$temp_snapshot" "$output_asset"
}

[[ -f "$ASSET" ]] || {
  echo "Missing documentation visual asset: $ASSET" >&2
  exit 1
}

[[ -f "$BASELINE_ASSET" ]] || {
  echo "Missing documentation visual baseline: $BASELINE_ASSET" >&2
  exit 1
}

xmllint --noout "$ASSET"

grep -q 'viewBox="' "$ASSET" || {
  echo "Missing viewBox in documentation visual asset." >&2
  exit 1
}

grep -q 'preserveAspectRatio="xMidYMid meet"' "$ASSET" || {
  echo "Missing preserveAspectRatio contract in documentation visual asset." >&2
  exit 1
}

grep -q 'font-family=' "$ASSET" || {
  echo "Missing font-family declaration in documentation visual asset." >&2
  exit 1
}

RASTERIZED_ASSET="$TMP_DIR/docs-board.png"
render_svg_snapshot "$ASSET" "1400" "$RASTERIZED_ASSET"

actual_width="$(sips -g pixelWidth "$RASTERIZED_ASSET" | awk '/pixelWidth/ {print $2}')"
actual_height="$(sips -g pixelHeight "$RASTERIZED_ASSET" | awk '/pixelHeight/ {print $2}')"
baseline_width="$(sips -g pixelWidth "$BASELINE_ASSET" | awk '/pixelWidth/ {print $2}')"
baseline_height="$(sips -g pixelHeight "$BASELINE_ASSET" | awk '/pixelHeight/ {print $2}')"

[[ "$actual_width" == "$baseline_width" ]] || {
  echo "Unexpected documentation board width: $actual_width" >&2
  exit 1
}

[[ "$actual_height" == "$baseline_height" ]] || {
  echo "Unexpected documentation board height: $actual_height" >&2
  exit 1
}

current_checksum="$(shasum -a 256 "$RASTERIZED_ASSET" | awk '{print $1}')"
baseline_checksum="$(shasum -a 256 "$BASELINE_ASSET" | awk '{print $1}')"

[[ "$current_checksum" == "$baseline_checksum" ]] || {
  echo "Documentation visual regression detected." >&2
  echo "Refresh baseline only if the redesign is intentional: bash Scripts/refresh-public-visual-baselines.sh" >&2
  exit 1
}

grep -q 'swiftintelligence-docs-board.svg' "$PAGE" || {
  echo "Documentation/README.md must reference swiftintelligence-docs-board.svg." >&2
  exit 1
}

echo "Documentation visual assets validated."
