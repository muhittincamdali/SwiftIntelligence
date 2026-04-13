#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
README_DIR="$ROOT_DIR/Documentation/Assets/Readme"
BASELINE_DIR="$README_DIR/Baselines"
MANIFEST_ASSET="$BASELINE_DIR/manifest.txt"
TMP_DIR="$(mktemp -d)"

source "$ROOT_DIR/Scripts/visual-asset-validation-lib.sh"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

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

for asset in "${required_assets[@]}"; do
  require_svg_contract "$asset" "README"
  validate_svg_source_checksum "$asset" "$MANIFEST_ASSET" "README"
done

for spec in "${snapshot_specs[@]}"; do
  IFS=: read -r filename raster_width <<<"$spec"
  source_asset="$README_DIR/$filename"
  rasterized_asset="$TMP_DIR/${filename%.svg}.png"
  baseline_asset="$BASELINE_DIR/${filename%.svg}.png"
  require_visual_baseline "$baseline_asset" "$MANIFEST_ASSET" "README"

  render_svg_snapshot "$source_asset" "$raster_width" "$rasterized_asset" "$TMP_DIR"
  validate_snapshot_dimensions "$rasterized_asset" "$baseline_asset" "README"
  validate_snapshot_checksum_if_renderer_matches "$rasterized_asset" "$baseline_asset" "$MANIFEST_ASSET" "README" "$filename"
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
