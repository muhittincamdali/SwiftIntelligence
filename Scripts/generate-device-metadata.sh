#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RESULTS_DIR="${1:-$ROOT_DIR/Benchmarks/Results/latest}"
OUTPUT_PATH="${2:-$RESULTS_DIR/device-metadata.json}"

if [[ "$RESULTS_DIR" != /* ]]; then
  RESULTS_DIR="$ROOT_DIR/$RESULTS_DIR"
fi

if [[ "$OUTPUT_PATH" != /* ]]; then
  OUTPUT_PATH="$ROOT_DIR/$OUTPUT_PATH"
fi

REPORT_PATH="$RESULTS_DIR/benchmark-report.json"
ENVIRONMENT_PATH="$RESULTS_DIR/environment.json"

for artifact in "$REPORT_PATH" "$ENVIRONMENT_PATH"; do
  if [[ ! -f "$artifact" ]]; then
    echo "Missing benchmark artifact: $artifact" >&2
    exit 1
  fi
done

mkdir -p "$(dirname "$OUTPUT_PATH")"

ruby - "$REPORT_PATH" "$ENVIRONMENT_PATH" "$OUTPUT_PATH" <<'RUBY'
require "json"
require "time"

report_path, environment_path, output_path = ARGV

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
sample_result = report.fetch("results").first || {}

platform_override = ENV["SI_BENCHMARK_PLATFORM_FAMILY"]
device_name_override = ENV["SI_BENCHMARK_DEVICE_NAME"]
device_model_override = ENV["SI_BENCHMARK_DEVICE_MODEL"]
device_class_override = ENV["SI_BENCHMARK_DEVICE_CLASS"]
soc_override = ENV["SI_BENCHMARK_SOC"]
notes_override = ENV["SI_BENCHMARK_NOTES"]

platform_family = platform_override.to_s.empty? ? (sample_result["platform"] || "Unknown") : platform_override
device_name = device_name_override.to_s.empty? ? (environment["hostname"] || "Unknown") : device_name_override
device_model = device_model_override.to_s.empty? ? (sample_result["deviceModel"] || "Unknown") : device_model_override
device_class = device_class_override.to_s.empty? ? derive_device_class(platform_family, device_model, device_name) : device_class_override

metadata = {
  generatedAt: Time.now.utc.iso8601,
  benchmarkProfile: report["profile"],
  platformFamily: platform_family,
  deviceName: device_name,
  deviceModel: device_model,
  deviceClass: device_class,
  operatingSystemVersion: environment["operatingSystemVersion"] || "Unknown",
  processorCount: environment["processorCount"].to_i,
  physicalMemory: environment["physicalMemory"].to_i,
  systemOnChip: soc_override.to_s.empty? ? nil : soc_override,
  notes: notes_override.to_s.empty? ? nil : notes_override,
  broadClaimEligible: device_class != "Unknown",
  sources: {
    platformFamily: platform_override.to_s.empty? ? "benchmark-report.json" : "environment override",
    deviceName: device_name_override.to_s.empty? ? "environment.json" : "environment override",
    deviceModel: device_model_override.to_s.empty? ? "benchmark-report.json" : "environment override",
    deviceClass: device_class_override.to_s.empty? ? "derived" : "environment override"
  }
}.compact

File.write(output_path, JSON.pretty_generate(metadata) + "\n")
puts "Device metadata generated at #{output_path}"
RUBY
