#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
READINESS_PATH="${1:-$ROOT_DIR/Documentation/Generated/Benchmark-Readiness.md}"
PACKETS_PATH="${2:-$ROOT_DIR/Documentation/Generated/Device-Capture-Packets.md}"
INTAKE_PATH="${3:-$ROOT_DIR/Documentation/Generated/Device-Evidence-Intake.md}"
OUTPUT_PATH="${4:-$ROOT_DIR/Documentation/Generated/Release-Blockers.md}"

if [[ "$READINESS_PATH" != /* ]]; then
  READINESS_PATH="$ROOT_DIR/$READINESS_PATH"
fi

if [[ "$PACKETS_PATH" != /* ]]; then
  PACKETS_PATH="$ROOT_DIR/$PACKETS_PATH"
fi

if [[ "$INTAKE_PATH" != /* ]]; then
  INTAKE_PATH="$ROOT_DIR/$INTAKE_PATH"
fi

if [[ "$OUTPUT_PATH" != /* ]]; then
  OUTPUT_PATH="$ROOT_DIR/$OUTPUT_PATH"
fi

mkdir -p "$(dirname "$OUTPUT_PATH")"

ruby - "$READINESS_PATH" "$PACKETS_PATH" "$INTAKE_PATH" "$OUTPUT_PATH" <<'RUBY'
readiness_path, packets_path, intake_path, output_path = ARGV

abort("Missing benchmark readiness report: #{readiness_path}") unless File.exist?(readiness_path)
abort("Missing device capture packets index: #{packets_path}") unless File.exist?(packets_path)
abort("Missing device evidence intake report: #{intake_path}") unless File.exist?(intake_path)

readiness = File.read(readiness_path)
packets = File.read(packets_path)
intake = File.read(intake_path)

publish_readiness = readiness[/Publish readiness: `([^`]+)`/, 1] || "unknown"
immutable_bundles = readiness[/Immutable release bundles: `([^`]+)`/, 1] || "unknown"
device_classes = readiness[/Device classes seen: `([^`]+)`/, 1] || "unknown"
missing_classes = readiness[/Missing required device classes from `device-matrix-policy\.json`: `([^`]+)`/, 1] || "none"

packet_classes = packets.scan(/^### ([^\n]+)$/).flatten
missing_class_list = missing_classes == "none" ? [] : missing_classes.split(",").map(&:strip).reject(&:empty?)
required_classes_summary = missing_class_list.empty? ? "the current required release classes" : missing_class_list.join(" and ")

File.open(output_path, "w") do |file|
  file.puts "# Release Blockers"
  file.puts
  file.puts "Generated summary of the blockers that still prevent release-grade public benchmark positioning."
  file.puts
  file.puts "## Headline"
  file.puts
  file.puts "- Publish readiness: `#{publish_readiness}`"
  file.puts "- Immutable release bundles: `#{immutable_bundles}`"
  file.puts "- Device classes seen: `#{device_classes}`"
  file.puts "- Missing required release device classes: `#{missing_classes}`"
  file.puts
  file.puts "## What Is Not Blocking"
  file.puts
  file.puts "- The active modular graph is building and testing cleanly."
  file.puts "- Benchmark artifacts, manifests, checksums, provenance, and threshold gates are in place."
  file.puts "- Transfer, import, and packetized handoff flows already exist."
  file.puts
  file.puts "## What Is Blocking"
  file.puts
  if missing_class_list.empty?
    file.puts "- No required release device classes are currently missing."
    file.puts "- Remaining work is release hygiene, optional extra device breadth, and positioning quality."
  else
    file.puts "- Broad public performance positioning is still blocked by missing non-Mac immutable release evidence."
    file.puts "- The repo still lacks archived `#{required_classes_summary}` benchmark bundle#{missing_class_list.length == 1 ? '' : 's'}."
    file.puts "- `Benchmark-Readiness.md` cannot move to `ready` until those device classes are archived and visible in generated coverage."
  end
  file.puts
  file.puts "## Immediate Execution Surface"
  file.puts
  file.puts "- Capture packets: [Device-Capture-Packets.md](Device-Capture-Packets.md)"
  file.puts "- Maintainer intake: [Device-Evidence-Intake.md](Device-Evidence-Intake.md)"
  file.puts "- Operational runbook: [Device-Evidence-Runbook.md](Device-Evidence-Runbook.md)"
  file.puts

  unless packet_classes.empty?
    file.puts "## Missing Device Waves"
    file.puts
    packet_classes.each do |device_class|
      slug = device_class.downcase
      file.puts "### #{device_class}"
      file.puts
      file.puts "- Packet README: [Device-Capture-Packets/#{slug}/README.md](Device-Capture-Packets/#{slug}/README.md)"
      file.puts "- Capture script: [Device-Capture-Packets/#{slug}/capture.sh](Device-Capture-Packets/#{slug}/capture.sh)"
      file.puts "- Import script: [Device-Capture-Packets/#{slug}/import.sh](Device-Capture-Packets/#{slug}/import.sh)"
      file.puts "- Intake template: [Device-Capture-Packets/#{slug}/issue-submission.md](Device-Capture-Packets/#{slug}/issue-submission.md)"
      file.puts
    end
  end

  file.puts "## Exit Condition"
  file.puts
  file.puts "- `Benchmark-Readiness.md` reports `ready`."
  file.puts "- `Device-Coverage-Matrix.md` includes all required release device classes from `device-matrix-policy.json`."
  file.puts "- `prepare-release.sh` still passes after the new bundles are archived."
end

puts "Release blockers report generated at #{output_path}"
RUBY
