#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DESTINATION_PATH=""
ARCHIVE_ROOT=""

usage() {
  cat <<'EOF'
Usage: bash Scripts/export-device-evidence-handoff.sh [options] <destination-path>

Packages the current missing-device execution surface into a transport archive for
an external operator who will capture or import iPhone/iPad benchmark evidence.

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

if [[ ${#POSITIONAL[@]} -ne 1 ]]; then
  usage >&2
  exit 1
fi

DESTINATION_PATH="${POSITIONAL[0]}"

if [[ "$DESTINATION_PATH" != /* ]]; then
  DESTINATION_PATH="$ROOT_DIR/$DESTINATION_PATH"
fi

QUEUE_JSON="$ROOT_DIR/Documentation/Generated/device-evidence-queue.json"
HANDOFF_MD="$ROOT_DIR/Documentation/Generated/Device-Evidence-Handoff.md"
HANDOFF_JSON="$ROOT_DIR/Documentation/Generated/device-evidence-handoff.json"

required_files=(
  "$QUEUE_JSON"
  "$HANDOFF_MD"
  "$HANDOFF_JSON"
  "$ROOT_DIR/Documentation/Generated/Device-Evidence-Queue.md"
  "$ROOT_DIR/Documentation/Generated/Device-Evidence-Intake.md"
  "$ROOT_DIR/Documentation/Generated/Device-Evidence-Runbook.md"
  "$ROOT_DIR/Documentation/Generated/Device-Capture-Packets.md"
  "$ROOT_DIR/Documentation/Generated/Device-Evidence-Plan.md"
  "$ROOT_DIR/Documentation/Generated/Device-Coverage-Matrix.md"
  "$ROOT_DIR/Documentation/Generated/Release-Blockers.md"
  "$ROOT_DIR/Documentation/Generated/Public-Proof-Status.md"
  "$ROOT_DIR/Documentation/Generated/public-proof-status.json"
  "$ROOT_DIR/.github/ISSUE_TEMPLATE/device_evidence.yml"
)

for path in "${required_files[@]}"; do
  if [[ ! -f "$path" ]]; then
    echo "Missing required handoff surface: $path" >&2
    exit 1
  fi
done

if [[ -z "$ARCHIVE_ROOT" ]]; then
  ARCHIVE_ROOT="device-evidence-handoff"
fi

mkdir -p "$(dirname "$DESTINATION_PATH")"

TEMP_DIR="$(mktemp -d "$ROOT_DIR/Documentation/Generated/handoff-stage.XXXXXX")"
trap 'if [[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]]; then rm -rf "$TEMP_DIR"; fi' EXIT

EXPORT_DIR="$TEMP_DIR/$ARCHIVE_ROOT"
mkdir -p "$EXPORT_DIR/Device-Capture-Packets"
mkdir -p "$EXPORT_DIR/GitHub"

cp "$HANDOFF_MD" "$EXPORT_DIR/Device-Evidence-Handoff.md"
cp "$HANDOFF_JSON" "$EXPORT_DIR/device-evidence-handoff.json"
cp "$ROOT_DIR/Documentation/Generated/Device-Evidence-Queue.md" "$EXPORT_DIR/Device-Evidence-Queue.md"
cp "$ROOT_DIR/Documentation/Generated/device-evidence-queue.json" "$EXPORT_DIR/device-evidence-queue.json"
cp "$ROOT_DIR/Documentation/Generated/Device-Evidence-Intake.md" "$EXPORT_DIR/Device-Evidence-Intake.md"
cp "$ROOT_DIR/Documentation/Generated/Device-Evidence-Runbook.md" "$EXPORT_DIR/Device-Evidence-Runbook.md"
cp "$ROOT_DIR/Documentation/Generated/Device-Capture-Packets.md" "$EXPORT_DIR/Device-Capture-Packets.md"
cp "$ROOT_DIR/Documentation/Generated/Device-Evidence-Plan.md" "$EXPORT_DIR/Device-Evidence-Plan.md"
cp "$ROOT_DIR/Documentation/Generated/Device-Coverage-Matrix.md" "$EXPORT_DIR/Device-Coverage-Matrix.md"
cp "$ROOT_DIR/Documentation/Generated/Release-Blockers.md" "$EXPORT_DIR/Release-Blockers.md"
cp "$ROOT_DIR/Documentation/Generated/Public-Proof-Status.md" "$EXPORT_DIR/Public-Proof-Status.md"
cp "$ROOT_DIR/Documentation/Generated/public-proof-status.json" "$EXPORT_DIR/public-proof-status.json"
cp "$ROOT_DIR/.github/ISSUE_TEMPLATE/device_evidence.yml" "$EXPORT_DIR/GitHub/device_evidence.yml"

device_classes=()
while IFS= read -r device_class; do
  device_classes+=("$device_class")
done < <(ruby -rjson -e 'payload = JSON.parse(File.read(ARGV[0])); Array(payload["entries"]).each { |entry| puts entry.fetch("deviceClass") }' "$QUEUE_JSON")

if [[ ${#device_classes[@]} -gt 0 ]]; then
  for device_class in "${device_classes[@]}"; do
    slug="$(echo "$device_class" | tr '[:upper:]' '[:lower:]')"
    source_dir="$ROOT_DIR/Documentation/Generated/Device-Capture-Packets/$slug"
    if [[ ! -d "$source_dir" ]]; then
      echo "Missing packet directory for $device_class: $source_dir" >&2
      exit 1
    fi

    cp -R "$source_dir" "$EXPORT_DIR/Device-Capture-Packets/$slug"
  done
fi

exported_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
git_commit="$(git -C "$ROOT_DIR" rev-parse HEAD 2>/dev/null || true)"
completion_command="$(ruby -rjson -e 'payload = JSON.parse(File.read(ARGV[0])); puts payload.fetch("completionCommand", "")' "$HANDOFF_JSON")"

ruby -rjson -e '
  payload = JSON.parse(File.read(ARGV[0]))
  manifest = {
    "exportedAt" => ARGV[1],
    "gitCommit" => ARGV[2],
    "archiveRoot" => ARGV[3],
    "queueSize" => payload.fetch("queueSize"),
    "deviceClasses" => Array(payload["deviceClasses"]),
    "distributionPosture" => payload.fetch("distributionPosture"),
    "publishReadiness" => payload.fetch("publishReadiness"),
    "completionCommand" => payload.fetch("completionCommand", "")
  }
  File.write(ARGV[4], JSON.pretty_generate(manifest) + "\n")
' "$HANDOFF_JSON" "$exported_at" "$git_commit" "$ARCHIVE_ROOT" "$EXPORT_DIR/handoff-manifest.json"

cat > "$EXPORT_DIR/README.md" <<EOF
# Device Evidence Handoff

This archive packages the current missing-device benchmark execution surface for an external operator.

- Exported at: \`$exported_at\`
- Git commit: \`${git_commit:-unknown}\`

## Start Here

1. Read \`Device-Evidence-Handoff.md\`
2. Pick the matching folder in \`Device-Capture-Packets/\`
3. Run its \`capture.sh\` on the source machine
4. Bring the exported benchmark archive back into a repo checkout
5. Run the matching \`import.sh\`
6. Use \`GitHub/device_evidence.yml\` plus packet-local \`issue-submission.md\`

## Close The Full Pending Wave

\`\`\`bash
$completion_command
\`\`\`

## Included

- queue, intake, runbook, and blocker docs
- per-device packet folders for the still-missing device classes
- public proof posture snapshot
- GitHub device evidence issue form
- handoff manifest
EOF

tar -czf "$DESTINATION_PATH" -C "$TEMP_DIR" "$ARCHIVE_ROOT"

echo "Exported device evidence handoff archive"
echo "Archive: $DESTINATION_PATH"
