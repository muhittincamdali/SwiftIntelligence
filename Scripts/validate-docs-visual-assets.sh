#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ASSET="$ROOT_DIR/Documentation/Assets/Docs/swiftintelligence-docs-board.svg"
BASELINE_ASSET="$ROOT_DIR/Documentation/Assets/Docs/Baselines/swiftintelligence-docs-board.png"
MANIFEST_ASSET="$ROOT_DIR/Documentation/Assets/Docs/Baselines/manifest.txt"
PAGE="$ROOT_DIR/Documentation/README.md"
TMP_DIR="$(mktemp -d)"

source "$ROOT_DIR/Scripts/visual-asset-validation-lib.sh"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT
require_svg_contract "$ASSET" "documentation"
require_visual_baseline "$BASELINE_ASSET" "$MANIFEST_ASSET" "documentation"
validate_svg_source_checksum "$ASSET" "$MANIFEST_ASSET" "Documentation"

RASTERIZED_ASSET="$TMP_DIR/docs-board.png"
render_svg_snapshot "$ASSET" "1400" "$RASTERIZED_ASSET" "$TMP_DIR"
validate_snapshot_dimensions "$RASTERIZED_ASSET" "$BASELINE_ASSET" "documentation"
validate_snapshot_checksum_if_renderer_matches "$RASTERIZED_ASSET" "$BASELINE_ASSET" "$MANIFEST_ASSET" "Documentation" "$(basename "$ASSET")"

grep -q 'swiftintelligence-docs-board.svg' "$PAGE" || {
  echo "Documentation/README.md must reference swiftintelligence-docs-board.svg." >&2
  exit 1
}

echo "Documentation visual assets validated."
