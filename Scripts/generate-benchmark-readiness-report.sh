#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RESULTS_ROOT="${1:-$ROOT_DIR/Benchmarks/Results}"
OUTPUT_PATH="${2:-$ROOT_DIR/Documentation/Generated/Benchmark-Readiness.md}"
THRESHOLDS_PATH="${3:-$ROOT_DIR/Benchmarks/benchmark-thresholds.json}"
DEVICE_POLICY_PATH="${4:-$ROOT_DIR/Benchmarks/device-matrix-policy.json}"

if [[ "$RESULTS_ROOT" != /* ]]; then
  RESULTS_ROOT="$ROOT_DIR/$RESULTS_ROOT"
fi

if [[ "$OUTPUT_PATH" != /* ]]; then
  OUTPUT_PATH="$ROOT_DIR/$OUTPUT_PATH"
fi

if [[ "$THRESHOLDS_PATH" != /* ]]; then
  THRESHOLDS_PATH="$ROOT_DIR/$THRESHOLDS_PATH"
fi

if [[ "$DEVICE_POLICY_PATH" != /* ]]; then
  DEVICE_POLICY_PATH="$ROOT_DIR/$DEVICE_POLICY_PATH"
fi

mkdir -p "$(dirname "$OUTPUT_PATH")"

ruby - "$ROOT_DIR" "$RESULTS_ROOT" "$OUTPUT_PATH" "$THRESHOLDS_PATH" "$DEVICE_POLICY_PATH" <<'RUBY'
require "json"
require "pathname"

root_dir, results_root, output_path, thresholds_path, device_policy_path = ARGV

def read_json(path)
  JSON.parse(File.read(path))
end

def safe_relative(root_dir, path)
  Pathname.new(path).relative_path_from(Pathname.new(root_dir)).to_s
rescue StandardError
  path
end

def load_snapshot(root_dir, dir_path, label:, type:)
  report_path = File.join(dir_path, "benchmark-report.json")
  summary_path = File.join(dir_path, "benchmark-summary.md")
  environment_path = File.join(dir_path, "environment.json")
  device_metadata_path = File.join(dir_path, "device-metadata.json")
  manifest_path = File.join(dir_path, "artifact-manifest.json")
  checksums_path = File.join(dir_path, "checksums.txt")
  metadata_path = File.join(dir_path, "metadata.json")

  return nil unless File.exist?(report_path) && File.exist?(summary_path) && File.exist?(environment_path)

  report = read_json(report_path)
  environment = read_json(environment_path)
  device_metadata = File.exist?(device_metadata_path) ? read_json(device_metadata_path) : {}
  sample_result = report.fetch("results").first || {}

  {
    label: label,
    type: type,
    dir_path: dir_path,
    dir_relative: safe_relative(root_dir, dir_path),
    profile: report["profile"],
    generated_at: report["generatedAt"],
    total_workloads: report.dig("analysis", "totalBenchmarks").to_i,
    platform: device_metadata["platformFamily"] || sample_result["platform"] || "Unknown",
    device_name: device_metadata["deviceName"] || environment["hostname"] || "Unknown",
    device_model: device_metadata["deviceModel"] || sample_result["deviceModel"] || "Unknown",
    device_class: device_metadata["deviceClass"] || device_class(sample_result["platform"], sample_result["deviceModel"]),
    os_version: device_metadata["operatingSystemVersion"] || environment["operatingSystemVersion"] || "Unknown",
    has_manifest: File.exist?(manifest_path),
    has_checksums: File.exist?(checksums_path),
    has_metadata: File.exist?(metadata_path),
    has_device_metadata: File.exist?(device_metadata_path)
  }
end

def device_class(platform, device_model)
  normalized_platform = platform.to_s.downcase
  normalized_model = device_model.to_s.downcase

  return "visionOS" if normalized_platform.include?("vision")
  return "Mac" if normalized_platform.include?("mac")
  return "iPad" if normalized_model.include?("ipad")
  return "iPhone" if normalized_model.include?("iphone")
  return "tvOS" if normalized_platform.include?("tv")
  return "watchOS" if normalized_platform.include?("watch")

  "Unknown"
end

snapshots = []
latest_snapshot = load_snapshot(root_dir, File.join(results_root, "latest"), label: "latest", type: "latest")
snapshots << latest_snapshot if latest_snapshot

releases_dir = File.join(results_root, "releases")
if Dir.exist?(releases_dir)
  Dir.children(releases_dir).sort.each do |child|
    dir_path = File.join(releases_dir, child)
    next unless File.directory?(dir_path)

    snapshot = load_snapshot(root_dir, dir_path, label: child, type: "release")
    snapshots << snapshot if snapshot
  end
end

release_snapshots = snapshots.select { |snapshot| snapshot[:type] == "release" }
device_classes = snapshots.map { |snapshot| snapshot[:device_class] }.uniq
thresholds = File.exist?(thresholds_path) ? read_json(thresholds_path) : {}
device_policy = File.exist?(device_policy_path) ? read_json(device_policy_path) : {}

minimum_device_classes = device_policy["minimumDeviceClasses"].to_i.positive? ? device_policy["minimumDeviceClasses"].to_i : 3
required_device_classes = Array(device_policy["requiredDeviceClasses"])
minimum_iterations_ready = latest_snapshot && latest_snapshot[:profile] == "standard"
covered_device_classes = device_classes.reject { |name| name == "Unknown" }
device_coverage_label = "At least #{minimum_device_classes} device classes covered"

readiness_rows = []
readiness_rows << ["Current benchmark artifacts exist", !latest_snapshot.nil?, latest_snapshot ? latest_snapshot[:dir_relative] : "missing"]
readiness_rows << ["Artifact manifest + checksums exist", latest_snapshot && latest_snapshot[:has_manifest] && latest_snapshot[:has_checksums], latest_snapshot ? "#{latest_snapshot[:has_manifest] ? 'manifest' : 'no manifest'}, #{latest_snapshot[:has_checksums] ? 'checksums' : 'no checksums'}" : "missing"]
readiness_rows << ["Explicit device metadata exists", latest_snapshot && latest_snapshot[:has_device_metadata], latest_snapshot ? (latest_snapshot[:has_device_metadata] ? "device-metadata.json" : "missing") : "missing"]
readiness_rows << ["Immutable release baseline exists", !release_snapshots.empty?, release_snapshots.empty? ? "no archived release evidence" : release_snapshots.first[:dir_relative]]
readiness_rows << [device_coverage_label, covered_device_classes.length >= minimum_device_classes, device_classes.join(", ")]
readiness_rows << ["Standard profile current run", minimum_iterations_ready, latest_snapshot ? latest_snapshot[:profile] : "missing"]
readiness_rows << ["Latest run has >= 25 workloads", latest_snapshot && latest_snapshot[:total_workloads] >= 25, latest_snapshot ? latest_snapshot[:total_workloads].to_s : "missing"]

publish_ready = readiness_rows.all? { |_, passed, _| passed }

File.open(output_path, "w") do |file|
  file.puts "# Benchmark Readiness"
  file.puts
  file.puts "Generated release-readiness and benchmark-publication checklist for the current artifact tree."
  file.puts
  file.puts "## Headline Status"
  file.puts
  file.puts "- Publish readiness: `#{publish_ready ? 'ready' : 'not ready'}`"
  file.puts "- Current pointer: `#{latest_snapshot ? latest_snapshot[:dir_relative] : 'missing'}`"
  file.puts "- Immutable release bundles: `#{release_snapshots.length}`"
  file.puts "- Device classes seen: `#{device_classes.join(', ')}`"
  file.puts "- Device matrix policy: `#{safe_relative(root_dir, device_policy_path)}`"
  file.puts
  file.puts "## Checklist"
  file.puts
  file.puts "| Check | Status | Evidence |"
  file.puts "| --- | --- | --- |"

  readiness_rows.each do |label, passed, evidence|
    file.puts "| #{label} | #{passed ? 'pass' : 'fail'} | #{evidence} |"
  end

  file.puts
  file.puts "## Current Environment Coverage"
  file.puts

  if snapshots.empty?
    file.puts "No readable benchmark artifacts were found."
  else
    file.puts "| Snapshot | Type | Device Class | Device Name | Device Model | Platform | OS | Profile | Workloads |"
    file.puts "| --- | --- | --- | --- | --- | --- | --- | --- | ---: |"

    snapshots.each do |snapshot|
      file.puts "| `#{snapshot[:label]}` | #{snapshot[:type]} | #{snapshot[:device_class]} | `#{snapshot[:device_name]}` | `#{snapshot[:device_model]}` | `#{snapshot[:platform]}` | `#{snapshot[:os_version]}` | `#{snapshot[:profile]}` | #{snapshot[:total_workloads]} |"
    end
  end

  file.puts
  file.puts "## Threshold Policy"
  file.puts

  if thresholds.empty?
    file.puts "Threshold policy file missing: `#{safe_relative(root_dir, thresholds_path)}`"
  else
    file.puts "- Performance score drop limit: `#{thresholds["maxPerformanceScoreDropPercent"]}%`"
    file.puts "- Average execution time increase limit: `#{thresholds["maxAverageExecutionTimeIncreasePercent"]}%`"
    file.puts "- Total memory increase limit: `#{thresholds["maxTotalMemoryIncreasePercent"]}%`"
    file.puts "- Per-workload execution time increase limit: `#{thresholds["maxPerWorkloadExecutionTimeIncreasePercent"]}%`"
    file.puts "- Per-workload peak memory increase limit: `#{thresholds["maxPerWorkloadPeakMemoryIncreasePercent"]}%`"
    file.puts "- Max regressed workload count: `#{thresholds["maxRegressedWorkloadCount"]}`"
  end

  file.puts
  file.puts "## Next Gaps"
  file.puts

  unless release_snapshots.any?
    file.puts "- Archive the current validated benchmark set into an immutable release bundle."
  end

  if covered_device_classes.length < minimum_device_classes
    file.puts "- Collect benchmark evidence on at least #{minimum_device_classes} device classes before making broad performance claims."
  end

  missing_required_classes = required_device_classes - device_classes
  unless missing_required_classes.empty?
    file.puts "- Missing required device classes from `device-matrix-policy.json`: `#{missing_required_classes.join(', ')}`."
  end

  unless minimum_iterations_ready
    file.puts "- Regenerate the current pointer using the `standard` benchmark profile."
  end

  if publish_ready
    file.puts "- Current evidence set satisfies the repository's minimum publish checklist."
  end
end

puts "Benchmark readiness report generated at #{output_path}"
RUBY
