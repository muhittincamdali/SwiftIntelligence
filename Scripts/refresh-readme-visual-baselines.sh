#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
README_DIR="$ROOT_DIR/Documentation/Assets/Readme"
BASELINE_DIR="$README_DIR/Baselines"

mkdir -p "$BASELINE_DIR"
rm -f "$BASELINE_DIR"/*.png

render_svg_snapshot() {
  local source_asset="$1"
  local raster_width="$2"
  local normalized_name="$3"
  local temp_dir

  temp_dir="$(mktemp -d)"

  qlmanage -t -s "$raster_width" -o "$temp_dir" "$source_asset" >/dev/null

  mv "$temp_dir/$(basename "$source_asset").png" "$BASELINE_DIR/$normalized_name"
  rm -rf "$temp_dir"
}

assets=(
  "swiftintelligence-hero.svg:1400"
  "swiftintelligence-capability-board.svg:1400"
  "swiftintelligence-architecture-board.svg:1400"
  "swiftintelligence-trust-board.svg:1400"
)

for spec in "${assets[@]}"; do
  IFS=: read -r filename raster_width <<<"$spec"
  source_asset="$README_DIR/$filename"
  render_svg_snapshot "$source_asset" "$raster_width" "${filename%.svg}.png"
done

echo "README visual baselines refreshed in $BASELINE_DIR"
