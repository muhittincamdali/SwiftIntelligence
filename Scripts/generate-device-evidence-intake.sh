#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKETS_INDEX_PATH="${1:-$ROOT_DIR/Documentation/Generated/Device-Capture-Packets.md}"
RUNBOOK_PATH="${2:-$ROOT_DIR/Documentation/Generated/Device-Evidence-Runbook.md}"
OUTPUT_PATH="${3:-$ROOT_DIR/Documentation/Generated/Device-Evidence-Intake.md}"

if [[ "$PACKETS_INDEX_PATH" != /* ]]; then
  PACKETS_INDEX_PATH="$ROOT_DIR/$PACKETS_INDEX_PATH"
fi

if [[ "$RUNBOOK_PATH" != /* ]]; then
  RUNBOOK_PATH="$ROOT_DIR/$RUNBOOK_PATH"
fi

if [[ "$OUTPUT_PATH" != /* ]]; then
  OUTPUT_PATH="$ROOT_DIR/$OUTPUT_PATH"
fi

mkdir -p "$(dirname "$OUTPUT_PATH")"

ruby - "$PACKETS_INDEX_PATH" "$RUNBOOK_PATH" "$OUTPUT_PATH" <<'RUBY'
packets_index_path, runbook_path, output_path = ARGV

abort("Missing device capture packets index: #{packets_index_path}") unless File.exist?(packets_index_path)
abort("Missing device evidence runbook: #{runbook_path}") unless File.exist?(runbook_path)

packets_index = File.read(packets_index_path)
runbook = File.read(runbook_path)

missing_classes = begin
  explicit = packets_index[/Missing required release device classes: `([^`]+)`/, 1]
  explicit ? explicit.split(",").map(&:strip).reject(&:empty?) : []
end

File.open(output_path, "w") do |file|
  file.puts "# Device Evidence Intake"
  file.puts
  file.puts "Generated maintainer intake summary for the device classes still blocking release-grade benchmark readiness."
  file.puts
  file.puts "## Current Gap"
  file.puts
  file.puts "- Missing required release device classes: `#{missing_classes.empty? ? 'none' : missing_classes.join(', ')}`"
  file.puts "- Capture packets: [Device-Capture-Packets.md](Device-Capture-Packets.md)"
  file.puts "- Runbook: [Device-Evidence-Runbook.md](Device-Evidence-Runbook.md)"
  file.puts "- Issue form: [../../.github/ISSUE_TEMPLATE/device_evidence.yml](../../.github/ISSUE_TEMPLATE/device_evidence.yml)"
  file.puts

  if missing_classes.empty?
    file.puts "## Status"
    file.puts
    file.puts "- No intake action is currently required."
  else
    file.puts "## Intake Steps"
    file.puts
    file.puts "1. Pick the matching device packet from `Device-Capture-Packets/<device-class>/`."
    file.puts "2. Run its `capture.sh` on the source machine, or receive the exported archive."
    file.puts "3. Run its `import.sh` in this checkout."
    file.puts "4. Open the `Device Evidence Submission` issue using the packet-local `issue-submission.md` and `issue-fields.json`."
    file.puts "5. Re-run `bash Scripts/prepare-release.sh` and verify generated coverage surfaces moved in the expected direction."
    file.puts
    file.puts "## Missing Device Classes"
    file.puts

    missing_classes.each do |device_class|
      slug = device_class.downcase
      file.puts "### #{device_class}"
      file.puts
      file.puts "- Packet README: [Device-Capture-Packets/#{slug}/README.md](Device-Capture-Packets/#{slug}/README.md)"
      file.puts "- Issue fields: [Device-Capture-Packets/#{slug}/issue-fields.json](Device-Capture-Packets/#{slug}/issue-fields.json)"
      file.puts "- Issue submission: [Device-Capture-Packets/#{slug}/issue-submission.md](Device-Capture-Packets/#{slug}/issue-submission.md)"
      file.puts
    end
  end
end

puts "Device evidence intake generated at #{output_path}"
RUBY
