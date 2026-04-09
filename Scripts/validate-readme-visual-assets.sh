#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
README_DIR="$ROOT_DIR/Documentation/Assets/Readme"
TMP_DIR="$(mktemp -d)"

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

expected_dimensions=(
  "swiftintelligence-hero.svg:1400:860"
  "swiftintelligence-capability-board.svg:1400:940"
  "swiftintelligence-architecture-board.svg:1400:900"
  "swiftintelligence-trust-board.svg:1400:920"
)

for asset in "${required_assets[@]}"; do
  [[ -f "$asset" ]] || {
    echo "Missing README visual asset: $asset" >&2
    exit 1
  }

  xmllint --noout "$asset"

  grep -q 'viewBox="' "$asset" || {
    echo "Missing viewBox in $asset" >&2
    exit 1
  }

  grep -q 'preserveAspectRatio="xMidYMid meet"' "$asset" || {
    echo "Missing preserveAspectRatio contract in $asset" >&2
    exit 1
  }

  grep -q 'font-family=' "$asset" || {
    echo "Missing font-family declaration in $asset" >&2
    exit 1
  }
done

for spec in "${expected_dimensions[@]}"; do
  IFS=: read -r filename expected_width expected_height <<<"$spec"
  source_asset="$README_DIR/$filename"
  rasterized_asset="$TMP_DIR/${filename%.svg}.png"

  sips -s format png "$source_asset" --out "$rasterized_asset" >/dev/null

  actual_width="$(sips -g pixelWidth "$rasterized_asset" | awk '/pixelWidth/ {print $2}')"
  actual_height="$(sips -g pixelHeight "$rasterized_asset" | awk '/pixelHeight/ {print $2}')"

  [[ "$actual_width" == "$expected_width" ]] || {
    echo "Unexpected rasterized width for $filename: $actual_width (expected $expected_width)" >&2
    exit 1
  }

  [[ "$actual_height" == "$expected_height" ]] || {
    echo "Unexpected rasterized height for $filename: $actual_height (expected $expected_height)" >&2
    exit 1
  }
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
