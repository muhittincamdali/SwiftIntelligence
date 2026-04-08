#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RESULTS_ROOT="${1:-$ROOT_DIR/Benchmarks/Results}"
POLICY_PATH="${2:-$ROOT_DIR/Benchmarks/device-matrix-policy.json}"

if [[ "$RESULTS_ROOT" != /* ]]; then
  RESULTS_ROOT="$ROOT_DIR/$RESULTS_ROOT"
fi

if [[ "$POLICY_PATH" != /* ]]; then
  POLICY_PATH="$ROOT_DIR/$POLICY_PATH"
fi

ruby - "$RESULTS_ROOT" "$POLICY_PATH" <<'RUBY'
require "json"
require "set"

results_root, policy_path = ARGV

abort("Missing benchmark results root: #{results_root}") unless Dir.exist?(results_root)
abort("Missing device matrix policy: #{policy_path}") unless File.exist?(policy_path)

policy = JSON.parse(File.read(policy_path))
recognized_classes = Array(policy["recognizedDeviceClasses"])
required_classes = Array(policy["requiredDeviceClasses"])

snapshots = []

candidate_dirs = []
latest_dir = File.join(results_root, "latest")
candidate_dirs << latest_dir if Dir.exist?(latest_dir)

releases_dir = File.join(results_root, "releases")
if Dir.exist?(releases_dir)
  Dir.children(releases_dir).sort.each do |child|
    dir = File.join(releases_dir, child)
    candidate_dirs << dir if File.directory?(dir)
  end
end

abort("No benchmark artifact directories found under #{results_root}") if candidate_dirs.empty?

candidate_dirs.each do |dir|
  report_path = File.join(dir, "benchmark-report.json")
  environment_path = File.join(dir, "environment.json")
  device_metadata_path = File.join(dir, "device-metadata.json")
  next unless File.exist?(report_path) && File.exist?(environment_path)

  abort("Missing device metadata for #{dir}") unless File.exist?(device_metadata_path)

  device_metadata = JSON.parse(File.read(device_metadata_path))
  benchmark_profile = device_metadata["benchmarkProfile"]
  device_class = device_metadata["deviceClass"]
  device_name = device_metadata["deviceName"]
  device_model = device_metadata["deviceModel"]
  platform_family = device_metadata["platformFamily"]

  abort("Invalid benchmarkProfile in #{device_metadata_path}") unless benchmark_profile.is_a?(String) && !benchmark_profile.empty?
  abort("Invalid deviceClass in #{device_metadata_path}") unless device_class.is_a?(String) && !device_class.empty?
  abort("Unrecognized deviceClass '#{device_class}' in #{device_metadata_path}") unless recognized_classes.include?(device_class)
  abort("Invalid deviceName in #{device_metadata_path}") unless device_name.is_a?(String) && !device_name.empty?
  abort("Invalid deviceModel in #{device_metadata_path}") unless device_model.is_a?(String) && !device_model.empty?
  abort("Invalid platformFamily in #{device_metadata_path}") unless platform_family.is_a?(String) && !platform_family.empty?

  source_map = device_metadata["sources"]
  abort("Missing sources map in #{device_metadata_path}") unless source_map.is_a?(Hash)

  metadata_path = File.join(dir, "metadata.json")
  is_release = File.exist?(metadata_path)
  if is_release
    metadata = JSON.parse(File.read(metadata_path))
    embedded_metadata = metadata["deviceMetadata"]
    abort("Release metadata missing embedded deviceMetadata in #{metadata_path}") unless embedded_metadata.is_a?(Hash)
    abort("Release metadata deviceClass mismatch in #{metadata_path}") unless embedded_metadata["deviceClass"] == device_class
  end

  snapshots << {
    dir: dir,
    release: is_release,
    device_class: device_class
  }
end

abort("No readable benchmark artifacts with device metadata found under #{results_root}") if snapshots.empty?

release_classes = snapshots.select { |snapshot| snapshot[:release] }.map { |snapshot| snapshot[:device_class] }.uniq
missing_release_classes = required_classes - release_classes

puts "Device evidence metadata validated for #{snapshots.length} artifact set(s)."
puts "Release device classes present: #{release_classes.empty? ? 'none' : release_classes.join(', ')}"
puts "Missing required release device classes: #{missing_release_classes.empty? ? 'none' : missing_release_classes.join(', ')}"
RUBY
