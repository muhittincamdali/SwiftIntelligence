#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
READINESS_PATH="${1:-$ROOT_DIR/Documentation/Generated/Benchmark-Readiness.md}"
OUTPUT_PATH="${2:-$ROOT_DIR/Documentation/Generated/Release-Candidate-Plan.md}"

if [[ "$READINESS_PATH" != /* ]]; then
  READINESS_PATH="$ROOT_DIR/$READINESS_PATH"
fi

if [[ "$OUTPUT_PATH" != /* ]]; then
  OUTPUT_PATH="$ROOT_DIR/$OUTPUT_PATH"
fi

mkdir -p "$(dirname "$OUTPUT_PATH")"

ruby - "$READINESS_PATH" "$OUTPUT_PATH" <<'RUBY'
readiness_path, output_path = ARGV
abort("Missing readiness report: #{readiness_path}") unless File.exist?(readiness_path)

content = File.read(readiness_path)
headline_status = content[/Publish readiness: `([^`]+)`/, 1] || "unknown"
device_classes = content[/Device classes seen: `([^`]+)`/, 1] || "unknown"
release_bundle_count = (content[/Immutable release bundles: `(\d+)`/, 1] || "0").to_i
has_release_baseline = release_bundle_count.positive? || content.include?("| Immutable release baseline exists | pass |")
coverage_row = content.lines.find { |line| line.include?("device classes covered") } || ""
coverage_label = coverage_row.split("|")[1]&.strip || "Device coverage"
has_required_device_coverage = coverage_row.include?("| pass |")
has_standard_profile = content.include?("| Standard profile current run | pass |")
has_workload_floor = content.include?("| Latest run has >= 25 workloads | pass |")
has_artifacts = content.include?("| Artifact manifest + checksums exist | pass |")
missing_required_classes = (content[/Missing required device classes from `device-matrix-policy\.json`: `([^`]+)`/, 1] || "")
  .split(",")
  .map(&:strip)
  .reject(&:empty?)

waves = []

unless has_release_baseline
  waves << {
    title: "Baseline Archive",
    goal: "Cut the first immutable benchmark evidence bundle from the current validated `latest` pointer.",
    steps: [
      "Run `bash Scripts/archive-benchmark-evidence.sh Benchmarks/Results/latest vX.Y.Z-rc-baseline`.",
      "Verify generated `release-proof.md`, `benchmark-delta.md`, `release-notes-proof.md`, `artifact-manifest.json`, and `checksums.txt`.",
      "Regenerate generated docs so `Release-Proof-Timeline.md` and `Latest-Release-Proof.md` stop reporting an empty release baseline."
    ]
  }
end

unless has_required_device_coverage
  missing_classes_phrase =
    if missing_required_classes.empty?
      "the remaining required device classes"
    else
      missing_required_classes.join(" and ")
    end

  waves << {
    title: "Device Coverage",
    goal: "Close the required release device coverage gap before treating benchmark proof as release-grade.",
    steps: [
      "Keep the current Mac baseline as the desktop/developer-workstation class.",
      "Add archived evidence for #{missing_classes_phrase}.",
      "Archive each validated device run into a release-style evidence bundle so the generated readiness surface can track #{coverage_label.downcase}."
    ]
  }
end

unless has_standard_profile && has_workload_floor && has_artifacts
  waves << {
    title: "Artifact Hygiene",
    goal: "Keep the current pointer publishable under the repository's minimum benchmark contract.",
    steps: [
      "Ensure the current pointer stays on the `standard` profile.",
      "Keep workload count at or above the current 25-workload floor.",
      "Keep manifest and checksum artifacts in sync with every regenerated benchmark payload."
    ]
  }
end

if waves.empty?
  waves << {
    title: "Release Candidate Execution",
    goal: "The benchmark surface is ready for a release candidate push.",
    steps: [
      "Run `bash Scripts/prepare-release.sh` on the final candidate commit.",
      "Archive the final immutable evidence bundle with the candidate tag.",
      "Push the matching tag only after changelog and proof surfaces are fully aligned."
    ]
  }
end

File.open(output_path, "w") do |file|
  file.puts "# Release Candidate Plan"
  file.puts
  file.puts "Generated from the current benchmark readiness report."
  file.puts
  file.puts "## Current State"
  file.puts
  file.puts "- Publish readiness: `#{headline_status}`"
  file.puts "- Device classes seen: `#{device_classes}`"
  file.puts "- Immutable release bundles: `#{release_bundle_count}`"
  file.puts "- Immutable release baseline: `#{has_release_baseline ? 'present' : 'missing'}`"
  file.puts "- Coverage rule: `#{coverage_label}`"
  file.puts

  waves.each_with_index do |wave, index|
    file.puts "## Wave #{index + 1}: #{wave[:title]}"
    file.puts
    file.puts "- Goal: #{wave[:goal]}"
    file.puts "- Steps:"
    wave[:steps].each do |step|
      file.puts "  - #{step}"
    end
    file.puts
  end

  file.puts "## Exit Condition"
  file.puts
  file.puts "- `Benchmark-Readiness.md` reports `ready`."
  file.puts "- At least one immutable release evidence bundle exists."
  file.puts "- Device coverage is broad enough that public performance claims are not Mac-only."
  file.puts "- `prepare-release.sh` completes without threshold failures or missing artifact gates."
end

puts "Release candidate plan generated at #{output_path}"
RUBY
