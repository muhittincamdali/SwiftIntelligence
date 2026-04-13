#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/Scripts/visual-asset-validation-lib.sh"

refresh_snapshot_group() {
  local source_asset="$1"
  local baseline_asset="$2"
  local manifest_asset="$3"
  local filename
  local baseline_dir
  local temp_dir

  filename="$(basename "$source_asset")"
  baseline_dir="$(dirname "$baseline_asset")"
  mkdir -p "$baseline_dir"
  temp_dir="$(mktemp -d)"

  {
    echo "renderer_major=$(host_renderer_major)"
    echo "$filename $(shasum -a 256 "$source_asset" | awk '{print $1}')"
  } >"$manifest_asset"

  render_svg_snapshot "$source_asset" "1400" "$baseline_asset" "$temp_dir"
  rm -rf "$temp_dir"
}

refresh_snapshot_group \
  "$ROOT_DIR/Documentation/Assets/Showcase/swiftintelligence-showcase-board.svg" \
  "$ROOT_DIR/Documentation/Assets/Showcase/Baselines/swiftintelligence-showcase-board.png" \
  "$ROOT_DIR/Documentation/Assets/Showcase/Baselines/manifest.txt"

refresh_snapshot_group \
  "$ROOT_DIR/Documentation/Assets/Comparisons/swiftintelligence-comparisons-board.svg" \
  "$ROOT_DIR/Documentation/Assets/Comparisons/Baselines/swiftintelligence-comparisons-board.png" \
  "$ROOT_DIR/Documentation/Assets/Comparisons/Baselines/manifest.txt"

refresh_snapshot_group \
  "$ROOT_DIR/Documentation/Assets/Docs/swiftintelligence-docs-board.svg" \
  "$ROOT_DIR/Documentation/Assets/Docs/Baselines/swiftintelligence-docs-board.png" \
  "$ROOT_DIR/Documentation/Assets/Docs/Baselines/manifest.txt"

echo "Public visual baselines refreshed."
