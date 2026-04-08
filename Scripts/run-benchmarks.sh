#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE="${1:-standard}"
OUTPUT_DIR="${2:-$ROOT_DIR/Benchmarks/Results/latest}"
SNAPSHOT_NAME="${3:-}"

cd "$ROOT_DIR"

echo "Running SwiftIntelligence benchmarks with profile '$PROFILE'..."
swift run -c release Benchmarks --profile "$PROFILE" --output-dir "$OUTPUT_DIR"
bash "$ROOT_DIR/Scripts/generate-device-metadata.sh" "$OUTPUT_DIR" >/dev/null
bash "$ROOT_DIR/Scripts/generate-artifact-manifest.sh" "$OUTPUT_DIR" >/dev/null
bash "$ROOT_DIR/Scripts/validate-benchmarks.sh" "$PROFILE" "$OUTPUT_DIR"

if [[ -n "$SNAPSHOT_NAME" ]]; then
  SNAPSHOT_DIR="$(bash "$ROOT_DIR/Scripts/archive-benchmark-evidence.sh" "$OUTPUT_DIR" "$SNAPSHOT_NAME")"
  echo "Immutable evidence archived at: $SNAPSHOT_DIR"
fi

echo "Artifacts available at: $OUTPUT_DIR"
