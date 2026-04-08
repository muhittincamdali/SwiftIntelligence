#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
READINESS_PATH="${1:-$ROOT_DIR/Documentation/Generated/Benchmark-Readiness.md}"
INTAKE_PATH="${2:-$ROOT_DIR/Documentation/Generated/Device-Evidence-Intake.md}"
OUTPUT_MD="${3:-$ROOT_DIR/Documentation/Generated/Device-Evidence-Queue.md}"
OUTPUT_JSON="${4:-$ROOT_DIR/Documentation/Generated/device-evidence-queue.json}"

if [[ "$READINESS_PATH" != /* ]]; then
  READINESS_PATH="$ROOT_DIR/$READINESS_PATH"
fi

if [[ "$INTAKE_PATH" != /* ]]; then
  INTAKE_PATH="$ROOT_DIR/$INTAKE_PATH"
fi

if [[ "$OUTPUT_MD" != /* ]]; then
  OUTPUT_MD="$ROOT_DIR/$OUTPUT_MD"
fi

if [[ "$OUTPUT_JSON" != /* ]]; then
  OUTPUT_JSON="$ROOT_DIR/$OUTPUT_JSON"
fi

mkdir -p "$(dirname "$OUTPUT_MD")"
mkdir -p "$(dirname "$OUTPUT_JSON")"

ruby - "$READINESS_PATH" "$INTAKE_PATH" "$OUTPUT_MD" "$OUTPUT_JSON" <<'RUBY'
require "json"

readiness_path, intake_path, output_md, output_json = ARGV

abort("Missing benchmark readiness report: #{readiness_path}") unless File.exist?(readiness_path)
abort("Missing device evidence intake report: #{intake_path}") unless File.exist?(intake_path)

readiness = File.read(readiness_path)
intake = File.read(intake_path)

publish_readiness = readiness[/Publish readiness: `([^`]+)`/, 1] || "unknown"
device_classes_seen = (readiness[/Device classes seen: `([^`]+)`/, 1] || "")
  .split(",")
  .map(&:strip)
  .reject(&:empty?)
missing_classes = (readiness[/Missing required device classes from `device-matrix-policy\.json`: `([^`]+)`/, 1] || "")
  .split(",")
  .map(&:strip)
  .reject(&:empty?)

queue_entries = missing_classes.map do |device_class|
  slug = device_class.downcase
  {
    "deviceClass" => device_class,
    "status" => "pending_external_evidence",
    "currentCoverage" => device_classes_seen,
    "packet" => "Documentation/Generated/Device-Capture-Packets/#{slug}/README.md",
    "captureScript" => "Documentation/Generated/Device-Capture-Packets/#{slug}/capture.sh",
    "importScript" => "Documentation/Generated/Device-Capture-Packets/#{slug}/import.sh",
    "issueFields" => "Documentation/Generated/Device-Capture-Packets/#{slug}/issue-fields.json",
    "issueSubmission" => "Documentation/Generated/Device-Capture-Packets/#{slug}/issue-submission.md",
    "blockingReason" => "Missing immutable release evidence for #{device_class}",
    "exitCondition" => "#{device_class} release bundle appears in Device-Coverage-Matrix.md"
  }
end

json_payload = {
  "publishReadiness" => publish_readiness,
  "queueSize" => queue_entries.length,
  "entries" => queue_entries
}

File.write(output_json, JSON.pretty_generate(json_payload) + "\n")

File.open(output_md, "w") do |file|
  file.puts "# Device Evidence Queue"
  file.puts
  file.puts "Generated execution queue for the device evidence waves still blocking release-grade benchmark positioning."
  file.puts
  file.puts "## Queue Status"
  file.puts
  file.puts "- Publish readiness: `#{publish_readiness}`"
  file.puts "- Queue size: `#{queue_entries.length}`"
  file.puts "- Machine-readable payload: [device-evidence-queue.json](device-evidence-queue.json)"
  file.puts

  if queue_entries.empty?
    file.puts "## State"
    file.puts
    file.puts "- No pending device evidence waves remain."
  else
    file.puts "## Queue"
    file.puts
    file.puts "| Device Class | Status | Blocking Reason | Packet |"
    file.puts "| --- | --- | --- | --- |"
    queue_entries.each do |entry|
      slug = entry.fetch("deviceClass").downcase
      file.puts "| `#{entry.fetch("deviceClass")}` | `#{entry.fetch("status")}` | #{entry.fetch("blockingReason")} | [packet](Device-Capture-Packets/#{slug}/README.md) |"
    end
    file.puts

    queue_entries.each do |entry|
      slug = entry.fetch("deviceClass").downcase
      file.puts "### #{entry.fetch("deviceClass")}"
      file.puts
      file.puts "- Status: `#{entry.fetch("status")}`"
      file.puts "- Packet: [Device-Capture-Packets/#{slug}/README.md](Device-Capture-Packets/#{slug}/README.md)"
      file.puts "- Capture script: [Device-Capture-Packets/#{slug}/capture.sh](Device-Capture-Packets/#{slug}/capture.sh)"
      file.puts "- Import script: [Device-Capture-Packets/#{slug}/import.sh](Device-Capture-Packets/#{slug}/import.sh)"
      file.puts "- Issue fields: [Device-Capture-Packets/#{slug}/issue-fields.json](Device-Capture-Packets/#{slug}/issue-fields.json)"
      file.puts "- Issue submission: [Device-Capture-Packets/#{slug}/issue-submission.md](Device-Capture-Packets/#{slug}/issue-submission.md)"
      file.puts "- Exit condition: #{entry.fetch("exitCondition")}"
      file.puts
    end
  end
end

puts "Device evidence queue generated at #{output_md}"
puts "Device evidence queue JSON generated at #{output_json}"
RUBY
