#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR=""
DESTINATION_PATH=""
ARCHIVE_ROOT=""

usage() {
  cat <<'EOF'
Usage: bash Scripts/export-benchmark-evidence.sh [options] <artifact-dir> <destination-path>

Packages a validated benchmark artifact directory into a transport archive that can
be moved to another machine and later imported with `Scripts/import-benchmark-evidence.sh`.

Options:
  --archive-root VALUE   Override the root folder name inside the archive
  --help                 Show this help
EOF
}

POSITIONAL=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --archive-root)
      ARCHIVE_ROOT="$2"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    --*)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
    *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done

if [[ ${#POSITIONAL[@]} -ne 2 ]]; then
  usage >&2
  exit 1
fi

SOURCE_DIR="${POSITIONAL[0]}"
DESTINATION_PATH="${POSITIONAL[1]}"

if [[ "$SOURCE_DIR" != /* ]]; then
  SOURCE_DIR="$ROOT_DIR/$SOURCE_DIR"
fi

if [[ "$DESTINATION_PATH" != /* ]]; then
  DESTINATION_PATH="$ROOT_DIR/$DESTINATION_PATH"
fi

if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "Artifact directory does not exist: $SOURCE_DIR" >&2
  exit 1
fi

mkdir -p "$(dirname "$DESTINATION_PATH")"

detected_profile="$(ruby -rjson -e 'report = JSON.parse(File.read(ARGV[0])); puts report.fetch("profile")' "$SOURCE_DIR/benchmark-report.json")"
bash "$ROOT_DIR/Scripts/validate-benchmarks.sh" "$detected_profile" "$SOURCE_DIR" >/dev/null

if [[ -z "$ARCHIVE_ROOT" ]]; then
  ARCHIVE_ROOT="$(basename "$SOURCE_DIR")-export"
fi

TEMP_DIR="$(mktemp -d "$ROOT_DIR/Benchmarks/Results/export-stage.XXXXXX")"
trap 'if [[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]]; then rm -rf "$TEMP_DIR"; fi' EXIT

EXPORT_DIR="$TEMP_DIR/$ARCHIVE_ROOT"
mkdir -p "$EXPORT_DIR"

required_artifacts=(
  "benchmark-report.json"
  "benchmark-summary.md"
  "environment.json"
  "device-metadata.json"
  "artifact-manifest.json"
  "checksums.txt"
)

for artifact in "${required_artifacts[@]}"; do
  if [[ ! -f "$SOURCE_DIR/$artifact" ]]; then
    echo "Missing required artifact for export: $SOURCE_DIR/$artifact" >&2
    exit 1
  fi

  cp "$SOURCE_DIR/$artifact" "$EXPORT_DIR/$artifact"
done

SOURCE_LABEL="$SOURCE_DIR"
EXPORTED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

cat > "$EXPORT_DIR/export-metadata.json" <<EOF
{
  "exportedAt": "$EXPORTED_AT",
  "sourceArtifactsDirectory": "$SOURCE_LABEL",
  "archiveRoot": "$ARCHIVE_ROOT",
  "profile": "$detected_profile"
}
EOF

cat > "$EXPORT_DIR/EXPORT_README.md" <<EOF
# Benchmark Evidence Export

This archive was exported from:

\`$SOURCE_LABEL\`

Detected profile: \`$detected_profile\`
- Exported at: \`$EXPORTED_AT\`

Import the archive directly into a SwiftIntelligence checkout:

\`\`\`bash
bash Scripts/import-benchmark-evidence.sh /absolute/path/to/benchmark-export.tar.gz <snapshot-name>
\`\`\`

If the destination repo needs normalized device overrides, pass:

\`\`\`bash
bash Scripts/import-benchmark-evidence.sh \\
  --device-name "<device name>" \\
  --device-model "<device model>" \\
  --device-class <Mac|iPhone|iPad|visionOS|tvOS|watchOS> \\
  --platform-family <macOS|iOS|iPadOS|visionOS|tvOS|watchOS> \\
  --soc "<SoC label>" \\
  /absolute/path/to/benchmark-export.tar.gz \\
  <snapshot-name>
\`\`\`
EOF

tar -czf "$DESTINATION_PATH" -C "$TEMP_DIR" "$ARCHIVE_ROOT"

echo "Exported benchmark evidence from $SOURCE_DIR"
echo "Archive: $DESTINATION_PATH"
