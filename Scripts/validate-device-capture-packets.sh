#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MATRIX_PATH="${1:-$ROOT_DIR/Documentation/Generated/Device-Coverage-Matrix.md}"
PACKETS_DIR="${2:-$ROOT_DIR/Documentation/Generated/Device-Capture-Packets}"
INDEX_PATH="${3:-$ROOT_DIR/Documentation/Generated/Device-Capture-Packets.md}"

if [[ "$MATRIX_PATH" != /* ]]; then
  MATRIX_PATH="$ROOT_DIR/$MATRIX_PATH"
fi

if [[ "$PACKETS_DIR" != /* ]]; then
  PACKETS_DIR="$ROOT_DIR/$PACKETS_DIR"
fi

if [[ "$INDEX_PATH" != /* ]]; then
  INDEX_PATH="$ROOT_DIR/$INDEX_PATH"
fi

ruby - "$MATRIX_PATH" "$PACKETS_DIR" "$INDEX_PATH" <<'RUBY'
require "json"

matrix_path, packets_dir, index_path = ARGV

abort("Missing device coverage matrix: #{matrix_path}") unless File.exist?(matrix_path)
abort("Missing device capture packet index: #{index_path}") unless File.exist?(index_path)

matrix = File.read(matrix_path)
missing_classes = begin
  explicit = matrix[/Missing required release device classes: `([^`]+)`/, 1]
  explicit ? explicit.split(",").map(&:strip).reject(&:empty?) : []
end

missing_classes.each do |device_class|
  slug = device_class.downcase
  packet_dir = File.join(packets_dir, slug)
  abort("Missing capture packet directory: #{packet_dir}") unless Dir.exist?(packet_dir)

  required_files = %w[README.md capture.sh import.sh device-metadata.json issue-fields.json issue-submission.md]
  required_files.each do |filename|
    path = File.join(packet_dir, filename)
    abort("Missing capture packet file: #{path}") unless File.exist?(path)
  end

  metadata_path = File.join(packet_dir, "device-metadata.json")
  metadata = JSON.parse(File.read(metadata_path))
  abort("Device class mismatch in #{metadata_path}") unless metadata["deviceClass"] == device_class

  issue_fields_path = File.join(packet_dir, "issue-fields.json")
  issue_fields = JSON.parse(File.read(issue_fields_path))
  abort("Issue fields device class mismatch in #{issue_fields_path}") unless issue_fields["device_class"] == device_class

  capture_script = File.join(packet_dir, "capture.sh")
  import_script = File.join(packet_dir, "import.sh")
  abort("Capture script is not executable: #{capture_script}") unless File.executable?(capture_script)
  abort("Import script is not executable: #{import_script}") unless File.executable?(import_script)
end

puts "Device capture packets validated for #{missing_classes.length} missing class(es)."
RUBY

while IFS= read -r script_path; do
  bash -n "$script_path"
done < <(find "$PACKETS_DIR" -type f \( -name "capture.sh" -o -name "import.sh" \) | sort)
