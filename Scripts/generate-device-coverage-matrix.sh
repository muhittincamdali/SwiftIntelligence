#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RESULTS_ROOT="${1:-$ROOT_DIR/Benchmarks/Results}"
POLICY_PATH="${2:-$ROOT_DIR/Benchmarks/device-matrix-policy.json}"
OUTPUT_PATH="${3:-$ROOT_DIR/Documentation/Generated/Device-Coverage-Matrix.md}"

if [[ "$RESULTS_ROOT" != /* ]]; then
  RESULTS_ROOT="$ROOT_DIR/$RESULTS_ROOT"
fi

if [[ "$POLICY_PATH" != /* ]]; then
  POLICY_PATH="$ROOT_DIR/$POLICY_PATH"
fi

if [[ "$OUTPUT_PATH" != /* ]]; then
  OUTPUT_PATH="$ROOT_DIR/$OUTPUT_PATH"
fi

mkdir -p "$(dirname "$OUTPUT_PATH")"

ruby - "$RESULTS_ROOT" "$POLICY_PATH" "$OUTPUT_PATH" <<'RUBY'
require "json"
require "time"

results_root, policy_path, output_path = ARGV

abort("Missing benchmark results root: #{results_root}") unless Dir.exist?(results_root)
abort("Missing device matrix policy: #{policy_path}") unless File.exist?(policy_path)

policy = JSON.parse(File.read(policy_path))
required_classes = Array(policy["requiredDeviceClasses"])
recognized_classes = Array(policy["recognizedDeviceClasses"])

snapshots = []

latest_dir = File.join(results_root, "latest")
if Dir.exist?(latest_dir)
  device_path = File.join(latest_dir, "device-metadata.json")
  report_path = File.join(latest_dir, "benchmark-report.json")
  if File.exist?(device_path) && File.exist?(report_path)
    device = JSON.parse(File.read(device_path))
    report = JSON.parse(File.read(report_path))
    snapshots << {
      label: "latest",
      type: "latest",
      generated_at: report["generatedAt"],
      archived_at: nil,
      profile: report["profile"],
      device_class: device["deviceClass"],
      device_name: device["deviceName"],
      device_model: device["deviceModel"],
      platform_family: device["platformFamily"],
      path: "Benchmarks/Results/latest"
    }
  end
end

releases_dir = File.join(results_root, "releases")
if Dir.exist?(releases_dir)
  Dir.children(releases_dir).sort.each do |child|
    dir = File.join(releases_dir, child)
    next unless File.directory?(dir)

    device_path = File.join(dir, "device-metadata.json")
    report_path = File.join(dir, "benchmark-report.json")
    metadata_path = File.join(dir, "metadata.json")
    next unless File.exist?(device_path) && File.exist?(report_path) && File.exist?(metadata_path)

    device = JSON.parse(File.read(device_path))
    report = JSON.parse(File.read(report_path))
    metadata = JSON.parse(File.read(metadata_path))

    snapshots << {
      label: child,
      type: "release",
      generated_at: report["generatedAt"],
      archived_at: metadata["archivedAt"],
      profile: report["profile"],
      device_class: device["deviceClass"],
      device_name: device["deviceName"],
      device_model: device["deviceModel"],
      platform_family: device["platformFamily"],
      path: "Benchmarks/Results/releases/#{child}"
    }
  end
end

grouped = snapshots.group_by { |snapshot| snapshot[:device_class] }

File.open(output_path, "w") do |file|
  file.puts "# Device Coverage Matrix"
  file.puts
  file.puts "Generated from benchmark device metadata and release evidence bundles."
  file.puts
  file.puts "## Policy Summary"
  file.puts
  file.puts "- Required device classes: `#{required_classes.join(', ')}`"
  file.puts "- Recognized device classes: `#{recognized_classes.join(', ')}`"
  file.puts
  file.puts "## Coverage Table"
  file.puts
  file.puts "| Device Class | Required | Latest Pointer | Release Evidence | Most Recent Device | Most Recent Archive |"
  file.puts "| --- | --- | --- | --- | --- | --- |"

  recognized_classes.reject { |name| name == "Unknown" }.each do |device_class|
    class_snapshots = grouped.fetch(device_class, [])
    latest_present = class_snapshots.any? { |snapshot| snapshot[:type] == "latest" }
    release_snapshots = class_snapshots.select { |snapshot| snapshot[:type] == "release" }
    latest_release = release_snapshots.max_by do |snapshot|
      Time.parse(snapshot[:archived_at] || snapshot[:generated_at] || "1970-01-01T00:00:00Z")
    rescue StandardError
      Time.at(0)
    end

    file.puts "| `#{device_class}` | #{required_classes.include?(device_class) ? 'yes' : 'no'} | #{latest_present ? 'yes' : 'no'} | #{release_snapshots.empty? ? 'no' : 'yes'} | #{latest_release ? "`#{latest_release[:device_name]}`" : 'n/a'} | #{latest_release ? "`#{latest_release[:label]}`" : 'n/a'} |"
  end

  file.puts
  file.puts "## Snapshot Index"
  file.puts

  if snapshots.empty?
    file.puts "No benchmark device metadata artifacts were found."
  else
    file.puts "| Snapshot | Type | Device Class | Device Name | Device Model | Platform | Profile | Generated | Archived |"
    file.puts "| --- | --- | --- | --- | --- | --- | --- | --- | --- |"

    snapshots.sort_by { |snapshot| [snapshot[:type] == "release" ? 0 : 1, snapshot[:archived_at] || snapshot[:generated_at] || ""] }.reverse.each do |snapshot|
      file.puts "| `#{snapshot[:label]}` | #{snapshot[:type]} | `#{snapshot[:device_class]}` | `#{snapshot[:device_name]}` | `#{snapshot[:device_model]}` | `#{snapshot[:platform_family]}` | `#{snapshot[:profile]}` | `#{snapshot[:generated_at]}` | `#{snapshot[:archived_at] || 'n/a'}` |"
    end
  end

  missing_required = required_classes.reject { |device_class| grouped.fetch(device_class, []).any? { |snapshot| snapshot[:type] == "release" } }
  file.puts
  file.puts "## Current Gaps"
  file.puts
  if missing_required.empty?
    file.puts "- Required release device classes are fully covered."
  else
    file.puts "- Missing required release device classes: `#{missing_required.join(', ')}`"
  end
end

puts "Device coverage matrix generated at #{output_path}"
RUBY
