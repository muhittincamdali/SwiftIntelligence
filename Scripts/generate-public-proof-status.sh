#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
READINESS_PATH="${1:-$ROOT_DIR/Documentation/Generated/Benchmark-Readiness.md}"
BLOCKERS_PATH="${2:-$ROOT_DIR/Documentation/Generated/Release-Blockers.md}"
MARKDOWN_OUTPUT="${3:-$ROOT_DIR/Documentation/Generated/Public-Proof-Status.md}"
JSON_OUTPUT="${4:-$ROOT_DIR/Documentation/Generated/public-proof-status.json}"
FLAGSHIP_MEDIA_STATUS_PATH="${5:-$ROOT_DIR/Documentation/Generated/Flagship-Media-Status.md}"
FLAGSHIP_MEDIA_JSON_PATH="${6:-$ROOT_DIR/Documentation/Generated/flagship-media-status.json}"

if [[ "$READINESS_PATH" != /* ]]; then
  READINESS_PATH="$ROOT_DIR/$READINESS_PATH"
fi

if [[ "$BLOCKERS_PATH" != /* ]]; then
  BLOCKERS_PATH="$ROOT_DIR/$BLOCKERS_PATH"
fi

if [[ "$MARKDOWN_OUTPUT" != /* ]]; then
  MARKDOWN_OUTPUT="$ROOT_DIR/$MARKDOWN_OUTPUT"
fi

if [[ "$JSON_OUTPUT" != /* ]]; then
  JSON_OUTPUT="$ROOT_DIR/$JSON_OUTPUT"
fi

if [[ "$FLAGSHIP_MEDIA_STATUS_PATH" != /* ]]; then
  FLAGSHIP_MEDIA_STATUS_PATH="$ROOT_DIR/$FLAGSHIP_MEDIA_STATUS_PATH"
fi

if [[ "$FLAGSHIP_MEDIA_JSON_PATH" != /* ]]; then
  FLAGSHIP_MEDIA_JSON_PATH="$ROOT_DIR/$FLAGSHIP_MEDIA_JSON_PATH"
fi

mkdir -p "$(dirname "$MARKDOWN_OUTPUT")"
mkdir -p "$(dirname "$JSON_OUTPUT")"

ruby - "$READINESS_PATH" "$BLOCKERS_PATH" "$MARKDOWN_OUTPUT" "$JSON_OUTPUT" "$FLAGSHIP_MEDIA_STATUS_PATH" "$FLAGSHIP_MEDIA_JSON_PATH" <<'RUBY'
require "json"

readiness_path, blockers_path, markdown_output, json_output, flagship_media_status_path, flagship_media_json_path = ARGV

abort("Missing benchmark readiness report: #{readiness_path}") unless File.exist?(readiness_path)
abort("Missing release blockers report: #{blockers_path}") unless File.exist?(blockers_path)
abort("Missing flagship media status: #{flagship_media_status_path}") unless File.exist?(flagship_media_status_path)
abort("Missing flagship media status JSON: #{flagship_media_json_path}") unless File.exist?(flagship_media_json_path)

readiness = File.read(readiness_path)
blockers = File.read(blockers_path)
flagship_media_status = File.read(flagship_media_status_path)
flagship_media_json = JSON.parse(File.read(flagship_media_json_path))

publish_readiness = readiness[/Publish readiness: `([^`]+)`/, 1] || "unknown"
immutable_bundles = readiness[/Immutable release bundles: `([^`]+)`/, 1] || "unknown"
device_classes = (readiness[/Device classes seen: `([^`]+)`/, 1] || "")
  .split(",")
  .map(&:strip)
  .reject(&:empty?)
missing_classes = (blockers[/Missing required release device classes: `([^`]+)`/, 1] || "")
  .split(",")
  .map(&:strip)
  .reject { |name| name.empty? || name == "none" }

distribution_posture =
  if publish_readiness == "ready"
    "release-grade"
  elsif missing_classes.empty?
    "restricted"
  else
    "developer-proof-only"
  end

allowed_claims = [
  "The active modular graph builds and tests cleanly.",
  "The flagship demo path has a dedicated guide and smoke-check.",
  "Benchmark artifacts, manifests, checksums, provenance, and threshold gates exist.",
  "A first immutable release baseline exists.",
  "Device capture, export, import, packet, and intake flows are implemented."
]

blocked_claims = []
if publish_readiness != "ready"
  blocked_claims << "Do not market benchmark coverage as release-grade."
  blocked_claims << "Do not present performance positioning as broad Apple-device proof."
end
if flagship_media_json["status"] != "published"
  blocked_claims << "Do not imply repo-native screenshot or video assets are already published."
end
unless missing_classes.empty?
  blocked_claims << "Do not claim multi-device benchmark coverage until #{missing_classes.join(' and ')} release bundles are archived."
end

next_actions = []
missing_classes.each do |device_class|
  slug = device_class.downcase
  next_actions << {
    "deviceClass" => device_class,
    "packet" => "Documentation/Generated/Device-Capture-Packets/#{slug}/README.md",
    "captureScript" => "Documentation/Generated/Device-Capture-Packets/#{slug}/capture.sh",
    "importScript" => "Documentation/Generated/Device-Capture-Packets/#{slug}/import.sh"
  }
end

json_payload = {
  "publishReadiness" => publish_readiness,
  "distributionPosture" => distribution_posture,
  "immutableReleaseBundles" => immutable_bundles.to_i,
  "deviceClassesSeen" => device_classes,
  "missingRequiredDeviceClasses" => missing_classes,
  "flagshipMediaStatus" => flagship_media_json["status"],
  "allowedClaims" => allowed_claims,
  "blockedClaims" => blocked_claims,
  "nextActions" => next_actions
}

File.write(json_output, JSON.pretty_generate(json_payload) + "\n")

File.open(markdown_output, "w") do |file|
  file.puts "# Public Proof Status"
  file.puts
  file.puts "Generated claim envelope for distribution, README language, release messaging, and public positioning."
  file.puts
  file.puts "## Status"
  file.puts
  file.puts "- Publish readiness: `#{publish_readiness}`"
  file.puts "- Distribution posture: `#{distribution_posture}`"
  file.puts "- Immutable release bundles: `#{immutable_bundles}`"
  file.puts "- Device classes seen: `#{device_classes.empty? ? 'none' : device_classes.join(', ')}`"
  file.puts "- Missing required device classes: `#{missing_classes.empty? ? 'none' : missing_classes.join(', ')}`"
  file.puts "- Flagship media status: `#{flagship_media_json["status"]}`"
  file.puts "- Machine-readable payload: [public-proof-status.json](public-proof-status.json)"
  file.puts
  file.puts "## Why Adopt Now"
  file.puts
  file.puts "- strongest proof path: `Vision -> NLP -> Privacy`"
  file.puts "- first demo guide: [../../Examples/DemoApps/IntelligentCamera/README.md](../../Examples/DemoApps/IntelligentCamera/README.md)"
  file.puts "- first immutable release proof: [Latest-Release-Proof.md](Latest-Release-Proof.md)"
  file.puts "- flagship media truth surface: [Flagship-Media-Status.md](Flagship-Media-Status.md)"
  file.puts
  file.puts "## Allowed Public Claims"
  file.puts
  allowed_claims.each do |claim|
    file.puts "- #{claim}"
  end
  file.puts
  file.puts "## Blocked Public Claims"
  file.puts
  if blocked_claims.empty?
    file.puts "- none"
  else
    blocked_claims.each do |claim|
      file.puts "- #{claim}"
    end
  end
  file.puts

  unless next_actions.empty?
    file.puts "## Next Actions"
    file.puts
    next_actions.each do |action|
      slug = action.fetch("deviceClass").downcase
      file.puts "### #{action.fetch("deviceClass")}"
      file.puts
      file.puts "- Packet: [Device-Capture-Packets/#{slug}/README.md](Device-Capture-Packets/#{slug}/README.md)"
      file.puts "- Capture script: [Device-Capture-Packets/#{slug}/capture.sh](Device-Capture-Packets/#{slug}/capture.sh)"
      file.puts "- Import script: [Device-Capture-Packets/#{slug}/import.sh](Device-Capture-Packets/#{slug}/import.sh)"
      file.puts
    end
  end
end

puts "Public proof status generated at #{markdown_output}"
puts "Public proof JSON generated at #{json_output}"
RUBY
