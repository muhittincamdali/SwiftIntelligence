#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR="${1:-$ROOT_DIR/Benchmarks/Results/latest}"

if [[ "$SOURCE_DIR" != /* ]]; then
  SOURCE_DIR="$ROOT_DIR/$SOURCE_DIR"
fi

if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "Missing benchmark artifact directory for transfer validation: $SOURCE_DIR" >&2
  exit 1
fi

TEMP_ARCHIVE="/tmp/swiftintelligence-transfer-validation.$$.$RANDOM.tar.gz"
TEMP_SNAPSHOT="codex-transfer-validation-temp"
TEMP_RELEASE_DIR="$ROOT_DIR/Benchmarks/Results/releases/$TEMP_SNAPSHOT"

cleanup() {
  rm -f "$TEMP_ARCHIVE"
  rm -rf "$TEMP_RELEASE_DIR"
}

trap cleanup EXIT

bash "$ROOT_DIR/Scripts/export-benchmark-evidence.sh" "$SOURCE_DIR" "$TEMP_ARCHIVE" >/dev/null
bash "$ROOT_DIR/Scripts/import-benchmark-evidence.sh" "$TEMP_ARCHIVE" "$TEMP_SNAPSHOT" >/dev/null

required_release_files=(
  "benchmark-report.json"
  "benchmark-summary.md"
  "environment.json"
  "device-metadata.json"
  "metadata.json"
  "release-proof.md"
  "artifact-manifest.json"
  "checksums.txt"
)

for artifact in "${required_release_files[@]}"; do
  if [[ ! -f "$TEMP_RELEASE_DIR/$artifact" ]]; then
    echo "Transfer validation failed; imported bundle is missing $artifact" >&2
    exit 1
  fi
done

echo "Benchmark transfer chain validated using $SOURCE_DIR"
