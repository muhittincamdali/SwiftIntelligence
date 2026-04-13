#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

refresh_snapshot() {
  local source_asset="$1"
  local baseline_asset="$2"
  local temp_dir

  temp_dir="$(mktemp -d)"
  mkdir -p "$(dirname "$baseline_asset")"

  qlmanage -t -s 1400 -o "$temp_dir" "$source_asset" >/dev/null
  mv "$temp_dir/$(basename "$source_asset").png" "$baseline_asset"
  rm -rf "$temp_dir"
}

refresh_snapshot \
  "$ROOT_DIR/Documentation/Assets/Showcase/swiftintelligence-showcase-board.svg" \
  "$ROOT_DIR/Documentation/Assets/Showcase/Baselines/swiftintelligence-showcase-board.png"

refresh_snapshot \
  "$ROOT_DIR/Documentation/Assets/Comparisons/swiftintelligence-comparisons-board.svg" \
  "$ROOT_DIR/Documentation/Assets/Comparisons/Baselines/swiftintelligence-comparisons-board.png"

refresh_snapshot \
  "$ROOT_DIR/Documentation/Assets/Docs/swiftintelligence-docs-board.svg" \
  "$ROOT_DIR/Documentation/Assets/Docs/Baselines/swiftintelligence-docs-board.png"

echo "Public visual baselines refreshed."
