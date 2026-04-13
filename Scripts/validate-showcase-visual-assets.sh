#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SHOWCASE_ASSET="$ROOT_DIR/Documentation/Assets/Showcase/swiftintelligence-showcase-board.svg"
BASELINE_ASSET="$ROOT_DIR/Documentation/Assets/Showcase/Baselines/swiftintelligence-showcase-board.png"
MANIFEST_ASSET="$ROOT_DIR/Documentation/Assets/Showcase/Baselines/manifest.txt"
SHOWCASE_PAGE="$ROOT_DIR/Documentation/Showcase.md"
TMP_DIR="$(mktemp -d)"

source "$ROOT_DIR/Scripts/visual-asset-validation-lib.sh"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT
require_svg_contract "$SHOWCASE_ASSET" "showcase"
require_visual_baseline "$BASELINE_ASSET" "$MANIFEST_ASSET" "showcase"
validate_svg_source_checksum "$SHOWCASE_ASSET" "$MANIFEST_ASSET" "Showcase"

RASTERIZED_ASSET="$TMP_DIR/showcase-board.png"
render_svg_snapshot "$SHOWCASE_ASSET" "1400" "$RASTERIZED_ASSET" "$TMP_DIR"
validate_snapshot_dimensions "$RASTERIZED_ASSET" "$BASELINE_ASSET" "showcase"
validate_snapshot_checksum_if_renderer_matches "$RASTERIZED_ASSET" "$BASELINE_ASSET" "$MANIFEST_ASSET" "Showcase" "$(basename "$SHOWCASE_ASSET")"

grep -q 'swiftintelligence-showcase-board.svg' "$SHOWCASE_PAGE" || {
  echo "Documentation/Showcase.md must reference swiftintelligence-showcase-board.svg." >&2
  exit 1
}

echo "Showcase visual assets validated."
