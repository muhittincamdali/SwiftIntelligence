#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXPECTED_PROFILE="${1:-standard}"
RESULTS_DIR="${2:-$ROOT_DIR/Benchmarks/Results/latest}"

REPORT_PATH="$RESULTS_DIR/benchmark-report.json"
SUMMARY_PATH="$RESULTS_DIR/benchmark-summary.md"
ENVIRONMENT_PATH="$RESULTS_DIR/environment.json"
DEVICE_METADATA_PATH="$RESULTS_DIR/device-metadata.json"
MANIFEST_PATH="$RESULTS_DIR/artifact-manifest.json"
CHECKSUMS_PATH="$RESULTS_DIR/checksums.txt"

for artifact in "$REPORT_PATH" "$SUMMARY_PATH" "$ENVIRONMENT_PATH" "$DEVICE_METADATA_PATH"; do
  if [[ ! -f "$artifact" ]]; then
    echo "Missing benchmark artifact: $artifact" >&2
    exit 1
  fi
done

ruby - "$REPORT_PATH" "$SUMMARY_PATH" "$ENVIRONMENT_PATH" "$DEVICE_METADATA_PATH" "$EXPECTED_PROFILE" <<'RUBY'
require "json"

report_path, summary_path, environment_path, device_metadata_path, expected_profile = ARGV

def derive_device_class(platform_family, device_model, device_name)
  normalized_platform = platform_family.to_s.downcase
  normalized_model = device_model.to_s.downcase
  normalized_name = device_name.to_s.downcase

  return "visionOS" if normalized_platform.include?("vision")
  return "Mac" if normalized_platform.include?("mac")
  return "iPad" if normalized_model.include?("ipad") || normalized_name.include?("ipad")
  return "iPhone" if normalized_model.include?("iphone") || normalized_name.include?("iphone")
  return "tvOS" if normalized_platform.include?("tv")
  return "watchOS" if normalized_platform.include?("watch")

  "Unknown"
end

report = JSON.parse(File.read(report_path))
environment = JSON.parse(File.read(environment_path))
device_metadata = JSON.parse(File.read(device_metadata_path))
summary = File.read(summary_path)

abort("benchmark report is missing profile") unless report["profile"].is_a?(String)
abort("benchmark report profile mismatch") unless report["profile"] == expected_profile
abort("environment profile mismatch") unless environment["profile"] == expected_profile
abort("benchmark report has no results") unless report["results"].is_a?(Array) && !report["results"].empty?
abort("analysis block missing") unless report["analysis"].is_a?(Hash)
abort("benchmark count mismatch") unless report["analysis"]["totalBenchmarks"] == report["results"].length
abort("frameworkVersion missing") unless report["frameworkVersion"].is_a?(String) && !report["frameworkVersion"].empty?
abort("generatedAt missing") unless report["generatedAt"].is_a?(String) && !report["generatedAt"].empty?
abort("hostname missing") unless environment["hostname"].is_a?(String) && !environment["hostname"].empty?
abort("processorCount invalid") unless environment["processorCount"].to_i > 0
abort("physicalMemory invalid") unless environment["physicalMemory"].to_i > 0
abort("device metadata profile mismatch") unless device_metadata["benchmarkProfile"] == expected_profile
abort("device name missing") unless device_metadata["deviceName"].is_a?(String) && !device_metadata["deviceName"].empty?
abort("device model missing") unless device_metadata["deviceModel"].is_a?(String) && !device_metadata["deviceModel"].empty?
abort("platform family missing") unless device_metadata["platformFamily"].is_a?(String) && !device_metadata["platformFamily"].empty?
abort("device class missing") unless device_metadata["deviceClass"].is_a?(String) && !device_metadata["deviceClass"].empty?
abort("device metadata OS mismatch") unless device_metadata["operatingSystemVersion"] == environment["operatingSystemVersion"]
abort("device metadata processor count mismatch") unless device_metadata["processorCount"].to_i == environment["processorCount"].to_i
abort("device metadata physical memory mismatch") unless device_metadata["physicalMemory"].to_i == environment["physicalMemory"].to_i

report["results"].each do |result|
  name = result["name"] || "unknown"
  measurements = result["measurements"]
  abort("measurements missing for #{name}") unless measurements.is_a?(Array) && !measurements.empty?
  abort("iterations mismatch for #{name}") unless result.dig("config", "iterations") == measurements.length

  avg = result["averageExecutionTime"].to_f
  min = result["minExecutionTime"].to_f
  max = result["maxExecutionTime"].to_f
  abort("execution time ordering invalid for #{name}") unless min <= avg && avg <= max
end

sample_result = report["results"].first || {}
derived_device_class = derive_device_class(device_metadata["platformFamily"], device_metadata["deviceModel"], device_metadata["deviceName"])
device_class_source = device_metadata.dig("sources", "deviceClass")
abort("device class is not normalized") unless device_class_source == "environment override" || device_metadata["deviceClass"] == derived_device_class || device_metadata["deviceClass"] == "Unknown"
abort("device metadata platform mismatch") unless sample_result["platform"].to_s.empty? || device_metadata["platformFamily"] == sample_result["platform"]

abort("summary missing expected profile") unless summary.include?("- Profile: `#{expected_profile}`")
abort("summary missing total workloads") unless summary.include?("- Total workloads: `#{report["results"].length}`")
abort("summary missing artifact contract") unless summary.include?("## Artifact Contract")
abort("summary missing benchmark-report reference") unless summary.include?("`benchmark-report.json`")
abort("summary missing environment reference") unless summary.include?("`environment.json`")
abort("summary missing device metadata reference") unless summary.include?("`device-metadata.json`")

puts "Benchmark artifacts validated for profile '#{expected_profile}'."
RUBY

if [[ -f "$MANIFEST_PATH" || -f "$CHECKSUMS_PATH" ]]; then
  ruby - "$RESULTS_DIR" "$MANIFEST_PATH" "$CHECKSUMS_PATH" <<'RUBY'
require "json"
require "digest"

results_dir, manifest_path, checksums_path = ARGV

abort("artifact manifest missing: #{manifest_path}") unless File.exist?(manifest_path)
abort("checksums file missing: #{checksums_path}") unless File.exist?(checksums_path)

manifest = JSON.parse(File.read(manifest_path))
files = manifest["files"]
abort("artifact manifest files missing") unless files.is_a?(Array) && !files.empty?
abort("artifact manifest file count mismatch") unless manifest["fileCount"].to_i == files.length

checksum_map = File.readlines(checksums_path, chomp: true).each_with_object({}) do |line, memo|
  next if line.strip.empty?
  sha, name = line.split(/\s+/, 2)
  abort("invalid checksum line: #{line}") if sha.nil? || name.nil?
  memo[name.strip] = sha.strip
end

files.each do |entry|
  name = entry["name"]
  path = File.join(results_dir, name)
  abort("manifest references missing file: #{path}") unless File.exist?(path)

  actual_sha = Digest::SHA256.file(path).hexdigest
  abort("manifest checksum mismatch for #{name}") unless actual_sha == entry["sha256"]
  abort("checksums.txt mismatch for #{name}") unless checksum_map[name] == actual_sha
end

puts "Artifact manifest and checksums validated."
RUBY
fi
