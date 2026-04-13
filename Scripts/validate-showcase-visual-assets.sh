#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SHOWCASE_ASSET="$ROOT_DIR/Documentation/Assets/Showcase/swiftintelligence-showcase-board.svg"
BASELINE_ASSET="$ROOT_DIR/Documentation/Assets/Showcase/Baselines/swiftintelligence-showcase-board.png"
SHOWCASE_PAGE="$ROOT_DIR/Documentation/Showcase.md"
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

[[ -f "$SHOWCASE_ASSET" ]] || {
  echo "Missing showcase visual asset: $SHOWCASE_ASSET" >&2
  exit 1
}

[[ -f "$BASELINE_ASSET" ]] || {
  echo "Missing showcase visual baseline: $BASELINE_ASSET" >&2
  exit 1
}

xmllint --noout "$SHOWCASE_ASSET"

grep -q 'viewBox="' "$SHOWCASE_ASSET" || {
  echo "Missing viewBox in showcase visual asset." >&2
  exit 1
}

grep -q 'preserveAspectRatio="xMidYMid meet"' "$SHOWCASE_ASSET" || {
  echo "Missing preserveAspectRatio contract in showcase visual asset." >&2
  exit 1
}

grep -q 'font-family=' "$SHOWCASE_ASSET" || {
  echo "Missing font-family declaration in showcase visual asset." >&2
  exit 1
}

RASTERIZED_ASSET="$TMP_DIR/showcase-board.png"
render_svg_snapshot "$SHOWCASE_ASSET" "1400" "$RASTERIZED_ASSET"

actual_width="$(sips -g pixelWidth "$RASTERIZED_ASSET" | awk '/pixelWidth/ {print $2}')"
actual_height="$(sips -g pixelHeight "$RASTERIZED_ASSET" | awk '/pixelHeight/ {print $2}')"
baseline_width="$(sips -g pixelWidth "$BASELINE_ASSET" | awk '/pixelWidth/ {print $2}')"
baseline_height="$(sips -g pixelHeight "$BASELINE_ASSET" | awk '/pixelHeight/ {print $2}')"

[[ "$actual_width" == "$baseline_width" ]] || {
  echo "Unexpected showcase board width: $actual_width" >&2
  exit 1
}

[[ "$actual_height" == "$baseline_height" ]] || {
  echo "Unexpected showcase board height: $actual_height" >&2
  exit 1
}

current_checksum="$(shasum -a 256 "$RASTERIZED_ASSET" | awk '{print $1}')"
baseline_checksum="$(shasum -a 256 "$BASELINE_ASSET" | awk '{print $1}')"

[[ "$current_checksum" == "$baseline_checksum" ]] || {
  echo "Showcase visual regression detected." >&2
  echo "Refresh baseline only if the redesign is intentional: bash Scripts/refresh-public-visual-baselines.sh" >&2
  exit 1
}

grep -q 'swiftintelligence-showcase-board.svg' "$SHOWCASE_PAGE" || {
  echo "Documentation/Showcase.md must reference swiftintelligence-showcase-board.svg." >&2
  exit 1
}

echo "Showcase visual assets validated."
