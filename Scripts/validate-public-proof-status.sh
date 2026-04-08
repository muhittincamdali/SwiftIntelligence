#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
READINESS_PATH="${1:-$ROOT_DIR/Documentation/Generated/Benchmark-Readiness.md}"
BLOCKERS_PATH="${2:-$ROOT_DIR/Documentation/Generated/Release-Blockers.md}"
MARKDOWN_PATH="${3:-$ROOT_DIR/Documentation/Generated/Public-Proof-Status.md}"
JSON_PATH="${4:-$ROOT_DIR/Documentation/Generated/public-proof-status.json}"
FLAGSHIP_MEDIA_JSON_PATH="${5:-$ROOT_DIR/Documentation/Generated/flagship-media-status.json}"

if [[ "$READINESS_PATH" != /* ]]; then
  READINESS_PATH="$ROOT_DIR/$READINESS_PATH"
fi

if [[ "$BLOCKERS_PATH" != /* ]]; then
  BLOCKERS_PATH="$ROOT_DIR/$BLOCKERS_PATH"
fi

if [[ "$MARKDOWN_PATH" != /* ]]; then
  MARKDOWN_PATH="$ROOT_DIR/$MARKDOWN_PATH"
fi

if [[ "$JSON_PATH" != /* ]]; then
  JSON_PATH="$ROOT_DIR/$JSON_PATH"
fi

if [[ "$FLAGSHIP_MEDIA_JSON_PATH" != /* ]]; then
  FLAGSHIP_MEDIA_JSON_PATH="$ROOT_DIR/$FLAGSHIP_MEDIA_JSON_PATH"
fi

ruby - "$READINESS_PATH" "$BLOCKERS_PATH" "$MARKDOWN_PATH" "$JSON_PATH" "$FLAGSHIP_MEDIA_JSON_PATH" <<'RUBY'
require "json"

readiness_path, blockers_path, markdown_path, json_path, flagship_media_json_path = ARGV

abort("Missing benchmark readiness report: #{readiness_path}") unless File.exist?(readiness_path)
abort("Missing release blockers report: #{blockers_path}") unless File.exist?(blockers_path)
abort("Missing public proof markdown: #{markdown_path}") unless File.exist?(markdown_path)
abort("Missing public proof JSON: #{json_path}") unless File.exist?(json_path)
abort("Missing flagship media status JSON: #{flagship_media_json_path}") unless File.exist?(flagship_media_json_path)

readiness = File.read(readiness_path)
blockers = File.read(blockers_path)
markdown = File.read(markdown_path)
json_payload = JSON.parse(File.read(json_path))
flagship_media_json = JSON.parse(File.read(flagship_media_json_path))

publish_readiness = readiness[/Publish readiness: `([^`]+)`/, 1] || "unknown"
device_classes = (readiness[/Device classes seen: `([^`]+)`/, 1] || "")
  .split(",")
  .map(&:strip)
  .reject(&:empty?)
missing_classes = (blockers[/Missing required release device classes: `([^`]+)`/, 1] || "")
  .split(",")
  .map(&:strip)
  .reject { |name| name.empty? || name == "none" }

expected_posture =
  if publish_readiness == "ready"
    "release-grade"
  elsif missing_classes.empty?
    "restricted"
  else
    "developer-proof-only"
  end

abort("publishReadiness mismatch in #{json_path}") unless json_payload["publishReadiness"] == publish_readiness
abort("distributionPosture mismatch in #{json_path}") unless json_payload["distributionPosture"] == expected_posture
abort("deviceClassesSeen mismatch in #{json_path}") unless Array(json_payload["deviceClassesSeen"]) == device_classes
abort("missingRequiredDeviceClasses mismatch in #{json_path}") unless Array(json_payload["missingRequiredDeviceClasses"]) == missing_classes
abort("flagshipMediaStatus mismatch in #{json_path}") unless json_payload["flagshipMediaStatus"] == flagship_media_json["status"]

abort("Markdown missing publish readiness line in #{markdown_path}") unless markdown.include?("- Publish readiness: `#{publish_readiness}`")
abort("Markdown missing distribution posture line in #{markdown_path}") unless markdown.include?("- Distribution posture: `#{expected_posture}`")
abort("Markdown missing flagship media status line in #{markdown_path}") unless markdown.include?("- Flagship media status: `#{flagship_media_json["status"]}`")

missing_classes.each do |device_class|
  abort("Markdown missing device action for #{device_class} in #{markdown_path}") unless markdown.include?("### #{device_class}")
end

blocked_claims = Array(json_payload["blockedClaims"])
blocked_claims.each do |claim|
  abort("Markdown missing blocked claim '#{claim}' in #{markdown_path}") unless markdown.include?("- #{claim}")
end

if missing_classes.empty?
  abort("Expected no nextActions in #{json_path}") unless Array(json_payload["nextActions"]).empty?
  abort("Unexpected 'none' device action in #{markdown_path}") if markdown.include?("### none")
end

puts "Public proof status validated for readiness '#{publish_readiness}' and posture '#{expected_posture}'."
RUBY
