#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ASSET="$ROOT_DIR/Documentation/Assets/Comparisons/swiftintelligence-comparisons-board.svg"
BASELINE_ASSET="$ROOT_DIR/Documentation/Assets/Comparisons/Baselines/swiftintelligence-comparisons-board.png"
MANIFEST_ASSET="$ROOT_DIR/Documentation/Assets/Comparisons/Baselines/manifest.txt"
PAGE="$ROOT_DIR/Documentation/Comparisons/README.md"
TMP_DIR="$(mktemp -d)"

source "$ROOT_DIR/Scripts/visual-asset-validation-lib.sh"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT
require_svg_contract "$ASSET" "comparison"
require_visual_baseline "$BASELINE_ASSET" "$MANIFEST_ASSET" "comparison"
validate_svg_source_checksum "$ASSET" "$MANIFEST_ASSET" "Comparison"

RASTERIZED_ASSET="$TMP_DIR/comparisons-board.png"
render_svg_snapshot "$ASSET" "1400" "$RASTERIZED_ASSET" "$TMP_DIR"
validate_snapshot_dimensions "$RASTERIZED_ASSET" "$BASELINE_ASSET" "comparison"
validate_snapshot_checksum_if_renderer_matches "$RASTERIZED_ASSET" "$BASELINE_ASSET" "$MANIFEST_ASSET" "Comparison" "$(basename "$ASSET")"

grep -q 'swiftintelligence-comparisons-board.svg' "$PAGE" || {
  echo "Documentation/Comparisons/README.md must reference swiftintelligence-comparisons-board.svg." >&2
  exit 1
}

echo "Comparison visual assets validated."
