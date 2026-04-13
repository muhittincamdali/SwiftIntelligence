#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
README_DIR="$ROOT_DIR/Documentation/Assets/Readme"
BASELINE_DIR="$README_DIR/Baselines"
MANIFEST_ASSET="$BASELINE_DIR/manifest.txt"

source "$ROOT_DIR/Scripts/visual-asset-validation-lib.sh"

mkdir -p "$BASELINE_DIR"
rm -f "$BASELINE_DIR"/*.png
rm -f "$MANIFEST_ASSET"

assets=(
  "swiftintelligence-hero.svg:1400"
  "swiftintelligence-capability-board.svg:1400"
  "swiftintelligence-architecture-board.svg:1400"
  "swiftintelligence-trust-board.svg:1400"
)

{
  echo "renderer_major=$(host_renderer_major)"
  for spec in "${assets[@]}"; do
    IFS=: read -r filename _ <<<"$spec"
    source_asset="$README_DIR/$filename"
    echo "$filename $(shasum -a 256 "$source_asset" | awk '{print $1}')"
  done
} >"$MANIFEST_ASSET"

for spec in "${assets[@]}"; do
  IFS=: read -r filename raster_width <<<"$spec"
  source_asset="$README_DIR/$filename"
  temp_dir="$(mktemp -d)"
  render_svg_snapshot "$source_asset" "$raster_width" "$BASELINE_DIR/${filename%.svg}.png" "$temp_dir"
  rm -rf "$temp_dir"
done

echo "README visual baselines refreshed in $BASELINE_DIR"
