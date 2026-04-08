#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
READINESS_PATH="${1:-$ROOT_DIR/Documentation/Generated/Benchmark-Readiness.md}"
QUEUE_MD="${2:-$ROOT_DIR/Documentation/Generated/Device-Evidence-Queue.md}"
QUEUE_JSON="${3:-$ROOT_DIR/Documentation/Generated/device-evidence-queue.json}"

if [[ "$READINESS_PATH" != /* ]]; then
  READINESS_PATH="$ROOT_DIR/$READINESS_PATH"
fi

if [[ "$QUEUE_MD" != /* ]]; then
  QUEUE_MD="$ROOT_DIR/$QUEUE_MD"
fi

if [[ "$QUEUE_JSON" != /* ]]; then
  QUEUE_JSON="$ROOT_DIR/$QUEUE_JSON"
fi

ruby - "$READINESS_PATH" "$QUEUE_MD" "$QUEUE_JSON" <<'RUBY'
require "json"

readiness_path, queue_md, queue_json = ARGV

abort("Missing benchmark readiness report: #{readiness_path}") unless File.exist?(readiness_path)
abort("Missing device evidence queue markdown: #{queue_md}") unless File.exist?(queue_md)
abort("Missing device evidence queue JSON: #{queue_json}") unless File.exist?(queue_json)

readiness = File.read(readiness_path)
markdown = File.read(queue_md)
payload = JSON.parse(File.read(queue_json))

publish_readiness = readiness[/Publish readiness: `([^`]+)`/, 1] || "unknown"
missing_classes = (readiness[/Missing required device classes from `device-matrix-policy\.json`: `([^`]+)`/, 1] || "")
  .split(",")
  .map(&:strip)
  .reject(&:empty?)

abort("Queue readiness mismatch") unless payload["publishReadiness"] == publish_readiness
abort("Queue size mismatch") unless payload["queueSize"].to_i == missing_classes.length

entries = Array(payload["entries"])
abort("Queue entry count mismatch") unless entries.length == missing_classes.length

missing_classes.each do |device_class|
  entry = entries.find { |candidate| candidate["deviceClass"] == device_class }
  abort("Missing queue entry for #{device_class}") unless entry
  abort("Queue markdown missing #{device_class}") unless markdown.include?("### #{device_class}")
  abort("Queue markdown missing packet link for #{device_class}") unless markdown.include?("Device-Capture-Packets/#{device_class.downcase}/README.md")
end

puts "Device evidence queue validated for #{missing_classes.length} pending class(es)."
RUBY
