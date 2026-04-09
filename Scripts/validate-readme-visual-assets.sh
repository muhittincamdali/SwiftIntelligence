#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
README_DIR="$ROOT_DIR/Documentation/Assets/Readme"

required_assets=(
  "$README_DIR/swiftintelligence-hero.svg"
  "$README_DIR/swiftintelligence-capability-board.svg"
  "$README_DIR/swiftintelligence-architecture-board.svg"
  "$README_DIR/swiftintelligence-trust-board.svg"
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
