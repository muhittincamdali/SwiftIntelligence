#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
QUEUE_JSON="$ROOT_DIR/Documentation/Generated/device-evidence-queue.json"
SKIP_PREPARE_RELEASE="false"

usage() {
  cat <<'EOF'
Usage: bash Scripts/complete-device-evidence-wave.sh [options]

Imports all currently pending device-evidence archives from the generated queue and,
by default, reruns the full release validation flow.

Options:
  --archive DEVICE=PATH      Provide a transfer archive for a pending device class
  --snapshot DEVICE=NAME     Provide the immutable snapshot name for that device class
  --skip-prepare-release     Import only; skip the final prepare-release run
  --help                     Show this help
EOF
}

declare -A ARCHIVES=()
declare -A SNAPSHOTS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --archive)
      assignment="$2"
      shift 2
      device_class="${assignment%%=*}"
      archive_path="${assignment#*=}"
      if [[ -z "$device_class" || -z "$archive_path" || "$assignment" != *=* ]]; then
        echo "Invalid --archive assignment: $assignment" >&2
        exit 1
      fi
      ARCHIVES["$device_class"]="$archive_path"
      ;;
    --snapshot)
      assignment="$2"
      shift 2
      device_class="${assignment%%=*}"
      snapshot_name="${assignment#*=}"
      if [[ -z "$device_class" || -z "$snapshot_name" || "$assignment" != *=* ]]; then
        echo "Invalid --snapshot assignment: $assignment" >&2
        exit 1
      fi
      SNAPSHOTS["$device_class"]="$snapshot_name"
      ;;
    --skip-prepare-release)
      SKIP_PREPARE_RELEASE="true"
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

mapfile -t pending_entries < <(ruby -rjson -e '
  payload = JSON.parse(File.read(ARGV[0]))
  abort("Device evidence queue is empty.") if payload.fetch("queueSize").to_i == 0
  Array(payload["entries"]).each do |entry|
    puts [entry.fetch("deviceClass"), entry.fetch("importScript")].join("\t")
  end
' "$QUEUE_JSON")

for line in "${pending_entries[@]}"; do
  IFS=$'\t' read -r device_class import_script <<<"$line"
  archive_path="${ARCHIVES[$device_class]:-}"
  snapshot_name="${SNAPSHOTS[$device_class]:-}"

  if [[ -z "$archive_path" ]]; then
    echo "Missing --archive assignment for pending device class: $device_class" >&2
    exit 1
  fi

  if [[ -z "$snapshot_name" ]]; then
    echo "Missing --snapshot assignment for pending device class: $device_class" >&2
    exit 1
  fi

  if [[ "$archive_path" != /* ]]; then
    archive_path="$ROOT_DIR/$archive_path"
  fi

  if [[ ! -f "$archive_path" ]]; then
    echo "Archive path does not exist for $device_class: $archive_path" >&2
    exit 1
  fi

  import_script_path="$ROOT_DIR/$import_script"
  if [[ ! -x "$import_script_path" ]]; then
    echo "Import script is missing or not executable for $device_class: $import_script_path" >&2
    exit 1
  fi

  echo "Importing $device_class evidence from $archive_path..."
  bash "$import_script_path" "$archive_path" "$snapshot_name"
done

if [[ "$SKIP_PREPARE_RELEASE" == "true" ]]; then
  echo "Device evidence import wave completed without final prepare-release validation."
  exit 0
fi

bash "$ROOT_DIR/Scripts/prepare-release.sh"

ruby -rjson -e '
  payload = JSON.parse(File.read(ARGV[0]))
  queue_size = payload.fetch("queueSize").to_i
  if queue_size.zero?
    puts "Device evidence queue cleared."
    exit 0
  end

  warn "Device evidence queue still has #{queue_size} pending class(es)."
  exit 1
' "$QUEUE_JSON"
