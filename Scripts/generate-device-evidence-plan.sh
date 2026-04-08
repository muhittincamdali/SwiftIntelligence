#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
READINESS_PATH="${1:-$ROOT_DIR/Documentation/Generated/Benchmark-Readiness.md}"
POLICY_PATH="${2:-$ROOT_DIR/Benchmarks/device-matrix-policy.json}"
OUTPUT_PATH="${3:-$ROOT_DIR/Documentation/Generated/Device-Evidence-Plan.md}"

if [[ "$READINESS_PATH" != /* ]]; then
  READINESS_PATH="$ROOT_DIR/$READINESS_PATH"
fi

if [[ "$POLICY_PATH" != /* ]]; then
  POLICY_PATH="$ROOT_DIR/$POLICY_PATH"
fi

if [[ "$OUTPUT_PATH" != /* ]]; then
  OUTPUT_PATH="$ROOT_DIR/$OUTPUT_PATH"
fi

mkdir -p "$(dirname "$OUTPUT_PATH")"

ruby - "$READINESS_PATH" "$POLICY_PATH" "$OUTPUT_PATH" <<'RUBY'
require "json"

readiness_path, policy_path, output_path = ARGV

abort("Missing readiness report: #{readiness_path}") unless File.exist?(readiness_path)
abort("Missing device matrix policy: #{policy_path}") unless File.exist?(policy_path)

readiness = File.read(readiness_path)
policy = JSON.parse(File.read(policy_path))

publish_readiness = readiness[/Publish readiness: `([^`]+)`/, 1] || "unknown"
current_classes = (readiness[/Device classes seen: `([^`]+)`/, 1] || "")
  .split(",")
  .map(&:strip)
  .reject(&:empty?)
required_classes = Array(policy["requiredDeviceClasses"])
minimum_classes = policy["minimumDeviceClasses"].to_i

missing_classes = begin
  explicit_missing = readiness[/Missing required device classes from `device-matrix-policy\.json`: `([^`]+)`/, 1]
  if explicit_missing
    explicit_missing.split(",").map(&:strip).reject(&:empty?)
  else
    required_classes - current_classes
  end
end

defaults = {
  "Mac" => {
    "output" => "Benchmarks/Results/mac-baseline",
    "snapshot" => "mac-baseline-<tag-or-date>",
    "device_name" => "MacBook Pro",
    "device_model" => "Mac16,1",
    "platform" => "macOS",
    "soc" => "Apple Silicon"
  },
  "iPhone" => {
    "output" => "Benchmarks/Results/iphone-baseline",
    "snapshot" => "iphone-baseline-<tag-or-date>",
    "device_name" => "iPhone 16",
    "device_model" => "iPhone17,3",
    "platform" => "iOS",
    "soc" => "Apple A18"
  },
  "iPad" => {
    "output" => "Benchmarks/Results/ipad-baseline",
    "snapshot" => "ipad-baseline-<tag-or-date>",
    "device_name" => "iPad Pro 13-inch (M4)",
    "device_model" => "iPad16,5",
    "platform" => "iPadOS",
    "soc" => "Apple M4"
  },
  "visionOS" => {
    "output" => "Benchmarks/Results/visionos-baseline",
    "snapshot" => "visionos-baseline-<tag-or-date>",
    "device_name" => "Apple Vision Pro",
    "device_model" => "RealityDevice14,1",
    "platform" => "visionOS",
    "soc" => "Apple M2"
  },
  "tvOS" => {
    "output" => "Benchmarks/Results/tvos-baseline",
    "snapshot" => "tvos-baseline-<tag-or-date>",
    "device_name" => "Apple TV 4K",
    "device_model" => "AppleTV14,1",
    "platform" => "tvOS",
    "soc" => "Apple A15"
  },
  "watchOS" => {
    "output" => "Benchmarks/Results/watchos-baseline",
    "snapshot" => "watchos-baseline-<tag-or-date>",
    "device_name" => "Apple Watch Ultra 2",
    "device_model" => "Watch7,5",
    "platform" => "watchOS",
    "soc" => "Apple S9"
  }
}

File.open(output_path, "w") do |file|
  file.puts "# Device Evidence Plan"
  file.puts
  file.puts "Generated from the current benchmark readiness report and device matrix policy."
  file.puts
  file.puts "## Current State"
  file.puts
  file.puts "- Publish readiness: `#{publish_readiness}`"
  file.puts "- Device classes already covered: `#{current_classes.join(', ')}`"
  file.puts "- Minimum device classes required: `#{minimum_classes}`"
  file.puts "- Required device classes: `#{required_classes.join(', ')}`"
  file.puts
  file.puts "## Matrix Rule"
  file.puts
  file.puts "- Do not treat hostname-only artifacts as enough evidence."
  file.puts "- Every new device run should go through `Scripts/run-benchmarks-for-device.sh`."
  file.puts "- Archive every validated run into `Benchmarks/Results/releases/<snapshot>` so generated proof pages can count it."
  file.puts

  if missing_classes.empty?
    file.puts "## Status"
    file.puts
    file.puts "- Required device classes from `device-matrix-policy.json` are already covered."
    file.puts "- Keep collecting release-grade runs only when hardware, OS, or workload methodology changes."
  else
    missing_classes.each_with_index do |device_class, index|
      defaults_for_class = defaults.fetch(device_class, {
        "output" => "Benchmarks/Results/#{device_class.downcase}-baseline",
        "snapshot" => "#{device_class.downcase}-baseline-<tag-or-date>",
        "device_name" => "#{device_class} Device",
        "device_model" => "#{device_class}Model",
        "platform" => device_class,
        "soc" => "Unknown"
      })

      file.puts "## Wave #{index + 1}: #{device_class} Evidence"
      file.puts
      file.puts "- Goal: add a validated `#{device_class}` benchmark run to the immutable evidence history."
      file.puts "- Capture command:"
      file.puts
      file.puts "```bash"
      file.puts "bash Scripts/run-benchmarks-for-device.sh \\"
      file.puts "  --profile standard \\"
      file.puts "  --output-dir #{defaults_for_class.fetch("output")} \\"
      file.puts "  --snapshot-name #{defaults_for_class.fetch("snapshot")} \\"
      file.puts "  --device-name \"#{defaults_for_class.fetch("device_name")}\" \\"
      file.puts "  --device-model \"#{defaults_for_class.fetch("device_model")}\" \\"
      file.puts "  --device-class #{device_class} \\"
      file.puts "  --platform-family #{defaults_for_class.fetch("platform")} \\"
      file.puts "  --soc \"#{defaults_for_class.fetch("soc")}\" \\"
      file.puts "  --export-archive /absolute/path/to/#{device_class.downcase}-benchmark-export.tar.gz"
      file.puts "```"
      file.puts
      file.puts "- After capture:"
      file.puts "  - confirm `device-metadata.json` reports `#{device_class}`"
      file.puts "  - confirm `validate-benchmarks.sh` passes for that output directory"
      file.puts "  - confirm the archive bundle appears in `Documentation/Generated/Release-Benchmark-Matrix.md` after docs regeneration"
      file.puts
    end
  end

  file.puts "## Exit Condition"
  file.puts
  file.puts "- `Benchmark-Readiness.md` reports `ready`."
  file.puts "- `device-matrix-policy.json` required classes all appear in generated readiness coverage."
  file.puts "- Release evidence is no longer Mac-only."
  file.puts "- `prepare-release.sh` still passes after docs regeneration."
end

puts "Device evidence plan generated at #{output_path}"
RUBY
