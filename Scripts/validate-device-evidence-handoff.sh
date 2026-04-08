#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
QUEUE_JSON="${1:-$ROOT_DIR/Documentation/Generated/device-evidence-queue.json}"
HANDOFF_MD="${2:-$ROOT_DIR/Documentation/Generated/Device-Evidence-Handoff.md}"
HANDOFF_JSON="${3:-$ROOT_DIR/Documentation/Generated/device-evidence-handoff.json}"

if [[ "$QUEUE_JSON" != /* ]]; then
  QUEUE_JSON="$ROOT_DIR/$QUEUE_JSON"
fi

if [[ "$HANDOFF_MD" != /* ]]; then
  HANDOFF_MD="$ROOT_DIR/$HANDOFF_MD"
fi

if [[ "$HANDOFF_JSON" != /* ]]; then
  HANDOFF_JSON="$ROOT_DIR/$HANDOFF_JSON"
fi

ruby - "$QUEUE_JSON" "$HANDOFF_MD" "$HANDOFF_JSON" <<'RUBY'
require "json"

queue_json_path, handoff_md_path, handoff_json_path = ARGV

abort("Missing device evidence queue JSON: #{queue_json_path}") unless File.exist?(queue_json_path)
abort("Missing device evidence handoff markdown: #{handoff_md_path}") unless File.exist?(handoff_md_path)
abort("Missing device evidence handoff JSON: #{handoff_json_path}") unless File.exist?(handoff_json_path)

queue_payload = JSON.parse(File.read(queue_json_path))
handoff_payload = JSON.parse(File.read(handoff_json_path))
handoff_md = File.read(handoff_md_path)

abort("Handoff queue size mismatch") unless handoff_payload["queueSize"].to_i == queue_payload["queueSize"].to_i
abort("Handoff publish readiness mismatch") unless handoff_payload["publishReadiness"] == queue_payload["publishReadiness"]

queue_entries = Array(queue_payload["entries"])
handoff_entries = Array(handoff_payload["entries"])
completion_command = handoff_payload.fetch("completionCommand", "")

abort("Handoff entry count mismatch") unless handoff_entries.length == queue_entries.length
abort("Handoff completion command missing") if !queue_entries.empty? && completion_command.strip.empty?
abort("Handoff markdown missing completion command") if !queue_entries.empty? && !handoff_md.include?("complete-device-evidence-wave.sh")

queue_entries.each do |entry|
  device_class = entry.fetch("deviceClass")
  slug = device_class.downcase

  abort("Handoff markdown missing #{device_class}") unless handoff_md.include?("### #{device_class}")
  abort("Handoff markdown missing packet README for #{device_class}") unless handoff_md.include?("Device-Capture-Packets/#{slug}/README.md")
  matching_entry = handoff_entries.find { |candidate| candidate["deviceClass"] == device_class }
  abort("Handoff JSON missing #{device_class}") unless matching_entry
  abort("Handoff JSON missing suggested archive for #{device_class}") unless matching_entry["suggestedArchive"] == "#{slug}-benchmark-export.tar.gz"
  abort("Handoff JSON missing suggested snapshot for #{device_class}") unless matching_entry["suggestedSnapshot"] == "#{slug}-baseline-<tag-or-date>"
end

puts "Device evidence handoff surfaces validated for #{queue_entries.length} pending class(es)."
RUBY

TEMP_ARCHIVE="/tmp/swiftintelligence-device-handoff.$$.$RANDOM.tar.gz"
trap 'rm -f "$TEMP_ARCHIVE"' EXIT

bash "$ROOT_DIR/Scripts/export-device-evidence-handoff.sh" "$TEMP_ARCHIVE" >/dev/null

mapfile -t archive_entries < <(tar -tzf "$TEMP_ARCHIVE")
archive_listing="$(printf '%s\n' "${archive_entries[@]}")"

required_archive_entries=(
  "device-evidence-handoff/README.md"
  "device-evidence-handoff/handoff-manifest.json"
  "device-evidence-handoff/Device-Evidence-Handoff.md"
  "device-evidence-handoff/device-evidence-handoff.json"
  "device-evidence-handoff/Device-Evidence-Queue.md"
  "device-evidence-handoff/device-evidence-queue.json"
  "device-evidence-handoff/Device-Evidence-Intake.md"
  "device-evidence-handoff/Device-Evidence-Runbook.md"
  "device-evidence-handoff/Device-Capture-Packets.md"
  "device-evidence-handoff/Device-Evidence-Plan.md"
  "device-evidence-handoff/Device-Coverage-Matrix.md"
  "device-evidence-handoff/Release-Blockers.md"
  "device-evidence-handoff/Public-Proof-Status.md"
  "device-evidence-handoff/public-proof-status.json"
  "device-evidence-handoff/GitHub/device_evidence.yml"
)

for entry in "${required_archive_entries[@]}"; do
  if ! grep -qx "$entry" <<<"$archive_listing"; then
    echo "Device evidence handoff archive is missing $entry" >&2
    exit 1
  fi
done

mapfile -t pending_classes < <(ruby -rjson -e 'payload = JSON.parse(File.read(ARGV[0])); Array(payload["entries"]).each { |entry| puts entry.fetch("deviceClass") }' "$QUEUE_JSON")

for device_class in "${pending_classes[@]}"; do
  slug="$(echo "$device_class" | tr '[:upper:]' '[:lower:]')"
  packet_entries=(
    "device-evidence-handoff/Device-Capture-Packets/$slug/README.md"
    "device-evidence-handoff/Device-Capture-Packets/$slug/capture.sh"
    "device-evidence-handoff/Device-Capture-Packets/$slug/import.sh"
    "device-evidence-handoff/Device-Capture-Packets/$slug/device-metadata.json"
    "device-evidence-handoff/Device-Capture-Packets/$slug/issue-fields.json"
    "device-evidence-handoff/Device-Capture-Packets/$slug/issue-submission.md"
  )

  for entry in "${packet_entries[@]}"; do
    if ! grep -qx "$entry" <<<"$archive_listing"; then
      echo "Device evidence handoff archive is missing $entry" >&2
      exit 1
    fi
  done
done

echo "Device evidence handoff archive validated."
