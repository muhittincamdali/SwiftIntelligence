#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
QUEUE_MD="${1:-$ROOT_DIR/Documentation/Generated/Device-Evidence-Queue.md}"
QUEUE_JSON="${2:-$ROOT_DIR/Documentation/Generated/device-evidence-queue.json}"
INTAKE_MD="${3:-$ROOT_DIR/Documentation/Generated/Device-Evidence-Intake.md}"
RUNBOOK_MD="${4:-$ROOT_DIR/Documentation/Generated/Device-Evidence-Runbook.md}"
PUBLIC_PROOF_JSON="${5:-$ROOT_DIR/Documentation/Generated/public-proof-status.json}"
OUTPUT_MD="${6:-$ROOT_DIR/Documentation/Generated/Device-Evidence-Handoff.md}"
OUTPUT_JSON="${7:-$ROOT_DIR/Documentation/Generated/device-evidence-handoff.json}"

if [[ "$QUEUE_MD" != /* ]]; then
  QUEUE_MD="$ROOT_DIR/$QUEUE_MD"
fi

if [[ "$QUEUE_JSON" != /* ]]; then
  QUEUE_JSON="$ROOT_DIR/$QUEUE_JSON"
fi

if [[ "$INTAKE_MD" != /* ]]; then
  INTAKE_MD="$ROOT_DIR/$INTAKE_MD"
fi

if [[ "$RUNBOOK_MD" != /* ]]; then
  RUNBOOK_MD="$ROOT_DIR/$RUNBOOK_MD"
fi

if [[ "$PUBLIC_PROOF_JSON" != /* ]]; then
  PUBLIC_PROOF_JSON="$ROOT_DIR/$PUBLIC_PROOF_JSON"
fi

if [[ "$OUTPUT_MD" != /* ]]; then
  OUTPUT_MD="$ROOT_DIR/$OUTPUT_MD"
fi

if [[ "$OUTPUT_JSON" != /* ]]; then
  OUTPUT_JSON="$ROOT_DIR/$OUTPUT_JSON"
fi

mkdir -p "$(dirname "$OUTPUT_MD")"
mkdir -p "$(dirname "$OUTPUT_JSON")"

ruby - "$QUEUE_MD" "$QUEUE_JSON" "$INTAKE_MD" "$RUNBOOK_MD" "$PUBLIC_PROOF_JSON" "$OUTPUT_MD" "$OUTPUT_JSON" <<'RUBY'
require "json"

queue_md_path, queue_json_path, intake_md_path, runbook_md_path, public_proof_json_path, output_md, output_json = ARGV

abort("Missing device evidence queue markdown: #{queue_md_path}") unless File.exist?(queue_md_path)
abort("Missing device evidence queue JSON: #{queue_json_path}") unless File.exist?(queue_json_path)
abort("Missing device evidence intake markdown: #{intake_md_path}") unless File.exist?(intake_md_path)
abort("Missing device evidence runbook markdown: #{runbook_md_path}") unless File.exist?(runbook_md_path)
abort("Missing public proof JSON: #{public_proof_json_path}") unless File.exist?(public_proof_json_path)

queue_payload = JSON.parse(File.read(queue_json_path))
public_proof = JSON.parse(File.read(public_proof_json_path))

publish_readiness = queue_payload.fetch("publishReadiness", "unknown")
distribution_posture = public_proof.fetch("distributionPosture", "unknown")
entries = Array(queue_payload["entries"])
device_classes = entries.map { |entry| entry.fetch("deviceClass") }
handoff_entries = entries.map do |entry|
  device_class = entry.fetch("deviceClass")
  slug = device_class.downcase

  entry.merge(
    "suggestedArchive" => "#{slug}-benchmark-export.tar.gz",
    "suggestedSnapshot" => "#{slug}-baseline-<tag-or-date>"
  )
end

completion_command = if handoff_entries.empty?
  ""
else
  lines = ["bash Scripts/complete-device-evidence-wave.sh \\"]
  handoff_entries.each_with_index do |entry, index|
    device_class = entry.fetch("deviceClass")
    archive_line = "  --archive #{device_class}=/absolute/path/to/#{entry.fetch("suggestedArchive")} \\"
    snapshot_suffix = index == handoff_entries.length - 1 ? "" : " \\"
    snapshot_line = "  --snapshot #{device_class}=#{entry.fetch("suggestedSnapshot")}#{snapshot_suffix}"
    lines << archive_line
    lines << snapshot_line
  end
  lines.join("\n")
end

json_payload = {
  "publishReadiness" => publish_readiness,
  "distributionPosture" => distribution_posture,
  "queueSize" => entries.length,
  "deviceClasses" => device_classes,
  "exportCommand" => "bash Scripts/export-device-evidence-handoff.sh /absolute/path/to/device-evidence-handoff.tar.gz",
  "completionCommand" => completion_command,
  "artifacts" => [
    "Documentation/Generated/Device-Evidence-Handoff.md",
    "Documentation/Generated/device-evidence-handoff.json",
    "Documentation/Generated/Device-Evidence-Queue.md",
    "Documentation/Generated/device-evidence-queue.json",
    "Documentation/Generated/Device-Evidence-Intake.md",
    "Documentation/Generated/Device-Evidence-Runbook.md",
    "Documentation/Generated/Device-Capture-Packets.md",
    "Documentation/Generated/Device-Evidence-Plan.md",
    "Documentation/Generated/Device-Coverage-Matrix.md",
    "Documentation/Generated/Release-Blockers.md",
    "Documentation/Generated/Public-Proof-Status.md",
    "Documentation/Generated/public-proof-status.json",
    ".github/ISSUE_TEMPLATE/device_evidence.yml"
  ],
  "entries" => handoff_entries
}

File.write(output_json, JSON.pretty_generate(json_payload) + "\n")

File.open(output_md, "w") do |file|
  file.puts "# Device Evidence Handoff"
  file.puts
  file.puts "Generated export surface for the missing device evidence waves that still block release-grade benchmark positioning."
  file.puts
  file.puts "## Status"
  file.puts
  file.puts "- Publish readiness: `#{publish_readiness}`"
  file.puts "- Distribution posture: `#{distribution_posture}`"
  file.puts "- Pending device classes: `#{device_classes.empty? ? 'none' : device_classes.join(', ')}`"
  file.puts "- Queue source: [Device-Evidence-Queue.md](Device-Evidence-Queue.md)"
  file.puts "- Intake source: [Device-Evidence-Intake.md](Device-Evidence-Intake.md)"
  file.puts "- Runbook source: [Device-Evidence-Runbook.md](Device-Evidence-Runbook.md)"
  file.puts "- Machine-readable payload: [device-evidence-handoff.json](device-evidence-handoff.json)"
  file.puts
  file.puts "## Export Command"
  file.puts
  file.puts "```bash"
  file.puts "bash Scripts/export-device-evidence-handoff.sh /absolute/path/to/device-evidence-handoff.tar.gz"
  file.puts "```"
  file.puts
  unless entries.empty?
    file.puts "## Completion Command"
    file.puts
    file.puts "```bash"
    file.puts completion_command
    file.puts "```"
    file.puts
  end

  file.puts "## Included Surfaces"
  file.puts
  file.puts "- queue summary and JSON payload"
  file.puts "- intake summary and maintainer runbook"
  file.puts "- packet index and per-device packet folders"
  file.puts "- release blockers and public proof envelope"
  file.puts "- GitHub `device_evidence` issue form"
  file.puts

  if entries.empty?
    file.puts "## State"
    file.puts
    file.puts "- No pending device evidence waves remain."
  else
    file.puts "## Pending Device Waves"
    file.puts
    handoff_entries.each do |entry|
      slug = entry.fetch("deviceClass").downcase
      file.puts "### #{entry.fetch("deviceClass")}"
      file.puts
      file.puts "- Packet README: [Device-Capture-Packets/#{slug}/README.md](Device-Capture-Packets/#{slug}/README.md)"
      file.puts "- Capture script: [Device-Capture-Packets/#{slug}/capture.sh](Device-Capture-Packets/#{slug}/capture.sh)"
      file.puts "- Import script: [Device-Capture-Packets/#{slug}/import.sh](Device-Capture-Packets/#{slug}/import.sh)"
      file.puts "- Issue fields: [Device-Capture-Packets/#{slug}/issue-fields.json](Device-Capture-Packets/#{slug}/issue-fields.json)"
      file.puts "- Issue submission: [Device-Capture-Packets/#{slug}/issue-submission.md](Device-Capture-Packets/#{slug}/issue-submission.md)"
      file.puts "- Suggested export archive: `#{entry.fetch("suggestedArchive")}`"
      file.puts "- Suggested snapshot name: `#{entry.fetch("suggestedSnapshot")}`"
      file.puts
    end
  end
end

puts "Device evidence handoff generated at #{output_md}"
puts "Device evidence handoff JSON generated at #{output_json}"
RUBY
