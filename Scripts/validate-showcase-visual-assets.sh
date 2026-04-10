#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SHOWCASE_ASSET="$ROOT_DIR/Documentation/Assets/Showcase/swiftintelligence-showcase-board.svg"
SHOWCASE_PAGE="$ROOT_DIR/Documentation/Showcase.md"
TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

[[ -f "$SHOWCASE_ASSET" ]] || {
  echo "Missing showcase visual asset: $SHOWCASE_ASSET" >&2
  exit 1
}

xmllint --noout "$SHOWCASE_ASSET"

grep -q 'viewBox="' "$SHOWCASE_ASSET" || {
  echo "Missing viewBox in showcase visual asset." >&2
  exit 1
}

grep -q 'preserveAspectRatio="xMidYMid meet"' "$SHOWCASE_ASSET" || {
  echo "Missing preserveAspectRatio contract in showcase visual asset." >&2
  exit 1
}

grep -q 'font-family=' "$SHOWCASE_ASSET" || {
  echo "Missing font-family declaration in showcase visual asset." >&2
  exit 1
}

RASTERIZED_ASSET="$TMP_DIR/showcase-board.png"
sips -s format png "$SHOWCASE_ASSET" --out "$RASTERIZED_ASSET" >/dev/null

actual_width="$(sips -g pixelWidth "$RASTERIZED_ASSET" | awk '/pixelWidth/ {print $2}')"
actual_height="$(sips -g pixelHeight "$RASTERIZED_ASSET" | awk '/pixelHeight/ {print $2}')"

[[ "$actual_width" == "1400" ]] || {
  echo "Unexpected showcase board width: $actual_width" >&2
  exit 1
}

[[ "$actual_height" == "880" ]] || {
  echo "Unexpected showcase board height: $actual_height" >&2
  exit 1
}

grep -q 'swiftintelligence-showcase-board.svg' "$SHOWCASE_PAGE" || {
  echo "Documentation/Showcase.md must reference swiftintelligence-showcase-board.svg." >&2
  exit 1
}

echo "Showcase visual assets validated."
