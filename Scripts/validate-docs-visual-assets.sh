#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ASSET="$ROOT_DIR/Documentation/Assets/Docs/swiftintelligence-docs-board.svg"
PAGE="$ROOT_DIR/Documentation/README.md"
TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

[[ -f "$ASSET" ]] || {
  echo "Missing documentation visual asset: $ASSET" >&2
  exit 1
}

xmllint --noout "$ASSET"

grep -q 'viewBox="' "$ASSET" || {
  echo "Missing viewBox in documentation visual asset." >&2
  exit 1
}

grep -q 'preserveAspectRatio="xMidYMid meet"' "$ASSET" || {
  echo "Missing preserveAspectRatio contract in documentation visual asset." >&2
  exit 1
}

grep -q 'font-family=' "$ASSET" || {
  echo "Missing font-family declaration in documentation visual asset." >&2
  exit 1
}

RASTERIZED_ASSET="$TMP_DIR/docs-board.png"
sips -s format png "$ASSET" --out "$RASTERIZED_ASSET" >/dev/null

actual_width="$(sips -g pixelWidth "$RASTERIZED_ASSET" | awk '/pixelWidth/ {print $2}')"
actual_height="$(sips -g pixelHeight "$RASTERIZED_ASSET" | awk '/pixelHeight/ {print $2}')"

[[ "$actual_width" == "1400" ]] || {
  echo "Unexpected documentation board width: $actual_width" >&2
  exit 1
}

[[ "$actual_height" == "900" ]] || {
  echo "Unexpected documentation board height: $actual_height" >&2
  exit 1
}

grep -q 'swiftintelligence-docs-board.svg' "$PAGE" || {
  echo "Documentation/README.md must reference swiftintelligence-docs-board.svg." >&2
  exit 1
}

echo "Documentation visual assets validated."
