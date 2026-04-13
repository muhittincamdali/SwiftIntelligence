#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
README_DIR="$ROOT_DIR/Documentation/Assets/Readme"
BASELINE_DIR="$README_DIR/Baselines"
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

required_assets=(
  "$README_DIR/swiftintelligence-hero.svg"
  "$README_DIR/swiftintelligence-capability-board.svg"
  "$README_DIR/swiftintelligence-architecture-board.svg"
  "$README_DIR/swiftintelligence-trust-board.svg"
)

snapshot_specs=(
  "swiftintelligence-hero.svg:1400"
  "swiftintelligence-capability-board.svg:1400"
  "swiftintelligence-architecture-board.svg:1400"
  "swiftintelligence-trust-board.svg:1400"
)

for baseline in \
  "$BASELINE_DIR/swiftintelligence-hero.png" \
  "$BASELINE_DIR/swiftintelligence-capability-board.png" \
  "$BASELINE_DIR/swiftintelligence-architecture-board.png" \
  "$BASELINE_DIR/swiftintelligence-trust-board.png"; do
  [[ -f "$baseline" ]] || {
    echo "Missing README visual baseline: $baseline" >&2
    exit 1
  }
done

for asset in "${required_assets[@]}"; do
  [[ -f "$asset" ]] || {
    echo "Missing README visual asset: $asset" >&2
    exit 1
  }

  xmllint --noout "$asset"

  grep -q 'viewBox="' "$asset" || {
    echo "Missing viewBox in $asset" >&2
    exit 1
  }

  grep -q 'preserveAspectRatio="xMidYMid meet"' "$asset" || {
    echo "Missing preserveAspectRatio contract in $asset" >&2
    exit 1
  }

  grep -q 'font-family=' "$asset" || {
    echo "Missing font-family declaration in $asset" >&2
    exit 1
  }
done

for spec in "${snapshot_specs[@]}"; do
  IFS=: read -r filename raster_width <<<"$spec"
  source_asset="$README_DIR/$filename"
  rasterized_asset="$TMP_DIR/${filename%.svg}.png"
  baseline_asset="$BASELINE_DIR/${filename%.svg}.png"

  render_svg_snapshot "$source_asset" "$raster_width" "$rasterized_asset"

  actual_width="$(sips -g pixelWidth "$rasterized_asset" | awk '/pixelWidth/ {print $2}')"
  actual_height="$(sips -g pixelHeight "$rasterized_asset" | awk '/pixelHeight/ {print $2}')"
  baseline_width="$(sips -g pixelWidth "$baseline_asset" | awk '/pixelWidth/ {print $2}')"
  baseline_height="$(sips -g pixelHeight "$baseline_asset" | awk '/pixelHeight/ {print $2}')"

  [[ "$actual_width" == "$baseline_width" ]] || {
    echo "Unexpected snapshot width for $filename: $actual_width (expected baseline $baseline_width)" >&2
    exit 1
  }

  [[ "$actual_height" == "$baseline_height" ]] || {
    echo "Unexpected snapshot height for $filename: $actual_height (expected baseline $baseline_height)" >&2
    exit 1
  }

  current_checksum="$(shasum -a 256 "$rasterized_asset" | awk '{print $1}')"
  baseline_checksum="$(shasum -a 256 "$baseline_asset" | awk '{print $1}')"

  [[ "$current_checksum" == "$baseline_checksum" ]] || {
    echo "README visual regression detected for $filename." >&2
    echo "Refresh baseline only if the visual redesign is intentional: bash Scripts/refresh-readme-visual-baselines.sh" >&2
    exit 1
  }
done

grep -q 'swiftintelligence-hero.svg' "$ROOT_DIR/README.md" || {
  echo "README.md must reference swiftintelligence-hero.svg." >&2
  exit 1
}

grep -q 'swiftintelligence-capability-board.svg' "$ROOT_DIR/README.md" || {
  echo "README.md must reference swiftintelligence-capability-board.svg." >&2
  exit 1
}

grep -q 'swiftintelligence-architecture-board.svg' "$ROOT_DIR/README.md" || {
  echo "README.md must reference swiftintelligence-architecture-board.svg." >&2
  exit 1
}

grep -q 'swiftintelligence-trust-board.svg' "$ROOT_DIR/README.md" || {
  echo "README.md must reference swiftintelligence-trust-board.svg." >&2
  exit 1
}

echo "README visual assets validated for ${#required_assets[@]} SVG surfaces."
