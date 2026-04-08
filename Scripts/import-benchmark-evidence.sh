#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_PATH=""
SNAPSHOT_NAME=""
DEVICE_NAME=""
DEVICE_MODEL=""
DEVICE_CLASS=""
PLATFORM_FAMILY=""
SYSTEM_ON_CHIP=""
NOTES=""
KEEP_STAGE="false"
STAGE_DIR=""
SOURCE_DIR=""
TEMP_IMPORT_ROOT=""
EXTRACTED_SOURCE_DIR=""
PROVENANCE_KIND="local-directory"
PROVENANCE_SOURCE=""
PROVENANCE_EXPORT_METADATA=""

usage() {
  cat <<'EOF'
Usage: bash Scripts/import-benchmark-evidence.sh [options] <source-dir> <snapshot-name>

Imports a benchmark artifact set captured on another machine or device into the
repository's immutable release evidence flow.
The source may be either an extracted directory or a `.tar.gz` export created by
`Scripts/export-benchmark-evidence.sh`.

Options:
  --device-name VALUE       Override device name for imported metadata
  --device-model VALUE      Override device model for imported metadata
  --device-class VALUE      Override normalized device class
  --platform-family VALUE   Override platform family
  --soc VALUE               Optional SoC label
  --notes VALUE             Optional metadata notes
  --keep-stage              Keep the temporary staged import directory
  --help                    Show this help
EOF
}

POSITIONAL=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --device-name)
      DEVICE_NAME="$2"
      shift 2
      ;;
    --device-model)
      DEVICE_MODEL="$2"
      shift 2
      ;;
    --device-class)
      DEVICE_CLASS="$2"
      shift 2
      ;;
    --platform-family)
      PLATFORM_FAMILY="$2"
      shift 2
      ;;
    --soc)
      SYSTEM_ON_CHIP="$2"
      shift 2
      ;;
    --notes)
      NOTES="$2"
      shift 2
      ;;
    --keep-stage)
      KEEP_STAGE="true"
      shift
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

SOURCE_PATH="${POSITIONAL[0]}"
SNAPSHOT_NAME="${POSITIONAL[1]}"

if [[ "$SOURCE_PATH" != /* ]]; then
  SOURCE_PATH="$ROOT_DIR/$SOURCE_PATH"
fi

if [[ ! -e "$SOURCE_PATH" ]]; then
  echo "Source path does not exist: $SOURCE_PATH" >&2
  exit 1
fi

TEMP_IMPORT_ROOT="$(mktemp -d "$ROOT_DIR/Benchmarks/Results/import-stage.XXXXXX")"
trap 'if [[ "$KEEP_STAGE" != "true" && -n "$TEMP_IMPORT_ROOT" && -d "$TEMP_IMPORT_ROOT" ]]; then rm -rf "$TEMP_IMPORT_ROOT"; fi' EXIT

if [[ -d "$SOURCE_PATH" ]]; then
  SOURCE_DIR="$SOURCE_PATH"
  PROVENANCE_KIND="directory-import"
  PROVENANCE_SOURCE="$SOURCE_PATH"
elif [[ -f "$SOURCE_PATH" && ( "$SOURCE_PATH" == *.tar.gz || "$SOURCE_PATH" == *.tgz ) ]]; then
  EXTRACTED_SOURCE_DIR="$TEMP_IMPORT_ROOT/extracted"
  mkdir -p "$EXTRACTED_SOURCE_DIR"
  tar -xzf "$SOURCE_PATH" -C "$EXTRACTED_SOURCE_DIR"

  extracted_dirs=()
  while IFS= read -r dir; do
    extracted_dirs+=("$dir")
  done < <(find "$EXTRACTED_SOURCE_DIR" -mindepth 1 -maxdepth 1 -type d | sort)

  if [[ ${#extracted_dirs[@]} -ne 1 ]]; then
    echo "Expected exactly one top-level directory inside archive: $SOURCE_PATH" >&2
    exit 1
  fi

  SOURCE_DIR="${extracted_dirs[0]}"
  PROVENANCE_KIND="archive-import"
  PROVENANCE_SOURCE="$SOURCE_PATH"
else
  echo "Unsupported source path. Expected a directory or .tar.gz archive: $SOURCE_PATH" >&2
  exit 1
fi

required_artifacts=(
  "benchmark-report.json"
  "benchmark-summary.md"
  "environment.json"
)

for artifact in "${required_artifacts[@]}"; do
  if [[ ! -f "$SOURCE_DIR/$artifact" ]]; then
    echo "Missing source artifact: $SOURCE_DIR/$artifact" >&2
    exit 1
  fi
done

STAGE_DIR="$TEMP_IMPORT_ROOT/staged"
mkdir -p "$STAGE_DIR"

cp "$SOURCE_DIR/benchmark-report.json" "$STAGE_DIR/benchmark-report.json"
cp "$SOURCE_DIR/benchmark-summary.md" "$STAGE_DIR/benchmark-summary.md"
cp "$SOURCE_DIR/environment.json" "$STAGE_DIR/environment.json"

if [[ -f "$SOURCE_DIR/device-metadata.json" ]]; then
  cp "$SOURCE_DIR/device-metadata.json" "$STAGE_DIR/device-metadata.json"
fi

if [[ -f "$SOURCE_DIR/export-metadata.json" ]]; then
  PROVENANCE_EXPORT_METADATA="$(cat "$SOURCE_DIR/export-metadata.json")"
fi

if [[ -n "$DEVICE_NAME" ]]; then
  export SI_BENCHMARK_DEVICE_NAME="$DEVICE_NAME"
fi

if [[ -n "$DEVICE_MODEL" ]]; then
  export SI_BENCHMARK_DEVICE_MODEL="$DEVICE_MODEL"
fi

if [[ -n "$DEVICE_CLASS" ]]; then
  export SI_BENCHMARK_DEVICE_CLASS="$DEVICE_CLASS"
fi

if [[ -n "$PLATFORM_FAMILY" ]]; then
  export SI_BENCHMARK_PLATFORM_FAMILY="$PLATFORM_FAMILY"
fi

if [[ -n "$SYSTEM_ON_CHIP" ]]; then
  export SI_BENCHMARK_SOC="$SYSTEM_ON_CHIP"
fi

if [[ -n "$NOTES" ]]; then
  export SI_BENCHMARK_NOTES="$NOTES"
fi

export SI_BENCHMARK_EVIDENCE_SOURCE_KIND="$PROVENANCE_KIND"
export SI_BENCHMARK_EVIDENCE_SOURCE_PATH="$PROVENANCE_SOURCE"

if [[ -n "$PROVENANCE_EXPORT_METADATA" ]]; then
  export SI_BENCHMARK_EXPORT_METADATA_JSON="$PROVENANCE_EXPORT_METADATA"
fi

bash "$ROOT_DIR/Scripts/generate-device-metadata.sh" "$STAGE_DIR" >/dev/null

detected_profile="$(ruby -rjson -e 'report = JSON.parse(File.read(ARGV[0])); puts report.fetch("profile")' "$STAGE_DIR/benchmark-report.json")"

bash "$ROOT_DIR/Scripts/generate-artifact-manifest.sh" "$STAGE_DIR" >/dev/null
bash "$ROOT_DIR/Scripts/validate-benchmarks.sh" "$detected_profile" "$STAGE_DIR" >/dev/null

ARCHIVED_PATH="$(bash "$ROOT_DIR/Scripts/archive-benchmark-evidence.sh" "$STAGE_DIR" "$SNAPSHOT_NAME")"

echo "Imported benchmark evidence from $SOURCE_PATH"
echo "Staged artifacts: $STAGE_DIR"
echo "Archived bundle: $ARCHIVED_PATH"
