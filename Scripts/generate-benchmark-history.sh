#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RESULTS_ROOT="${1:-$ROOT_DIR/Benchmarks/Results}"
HISTORY_OUTPUT="${2:-$ROOT_DIR/Documentation/Generated/Benchmark-History.md}"
COMPARISON_OUTPUT="${3:-$ROOT_DIR/Documentation/Generated/Benchmark-Comparison.md}"
METHODOLOGY_OUTPUT="${4:-$ROOT_DIR/Documentation/Generated/Benchmark-Methodology.md}"
TIMELINE_OUTPUT="${5:-$ROOT_DIR/Documentation/Generated/Benchmark-Timeline.md}"
RELEASE_MATRIX_OUTPUT="${6:-$ROOT_DIR/Documentation/Generated/Release-Benchmark-Matrix.md}"
RELEASE_TIMELINE_OUTPUT="${7:-$ROOT_DIR/Documentation/Generated/Release-Proof-Timeline.md}"
LATEST_RELEASE_OUTPUT="${8:-$ROOT_DIR/Documentation/Generated/Latest-Release-Proof.md}"

if [[ "$RESULTS_ROOT" != /* ]]; then
  RESULTS_ROOT="$ROOT_DIR/$RESULTS_ROOT"
fi

if [[ "$HISTORY_OUTPUT" != /* ]]; then
  HISTORY_OUTPUT="$ROOT_DIR/$HISTORY_OUTPUT"
fi

if [[ "$COMPARISON_OUTPUT" != /* ]]; then
  COMPARISON_OUTPUT="$ROOT_DIR/$COMPARISON_OUTPUT"
fi

if [[ "$METHODOLOGY_OUTPUT" != /* ]]; then
  METHODOLOGY_OUTPUT="$ROOT_DIR/$METHODOLOGY_OUTPUT"
fi

if [[ "$TIMELINE_OUTPUT" != /* ]]; then
  TIMELINE_OUTPUT="$ROOT_DIR/$TIMELINE_OUTPUT"
fi

if [[ "$RELEASE_MATRIX_OUTPUT" != /* ]]; then
  RELEASE_MATRIX_OUTPUT="$ROOT_DIR/$RELEASE_MATRIX_OUTPUT"
fi

if [[ "$RELEASE_TIMELINE_OUTPUT" != /* ]]; then
  RELEASE_TIMELINE_OUTPUT="$ROOT_DIR/$RELEASE_TIMELINE_OUTPUT"
fi

if [[ "$LATEST_RELEASE_OUTPUT" != /* ]]; then
  LATEST_RELEASE_OUTPUT="$ROOT_DIR/$LATEST_RELEASE_OUTPUT"
fi

mkdir -p "$(dirname "$HISTORY_OUTPUT")"
mkdir -p "$(dirname "$COMPARISON_OUTPUT")"
mkdir -p "$(dirname "$METHODOLOGY_OUTPUT")"
mkdir -p "$(dirname "$TIMELINE_OUTPUT")"
mkdir -p "$(dirname "$RELEASE_MATRIX_OUTPUT")"
mkdir -p "$(dirname "$RELEASE_TIMELINE_OUTPUT")"
mkdir -p "$(dirname "$LATEST_RELEASE_OUTPUT")"

ruby - "$ROOT_DIR" "$RESULTS_ROOT" "$HISTORY_OUTPUT" "$COMPARISON_OUTPUT" "$METHODOLOGY_OUTPUT" "$TIMELINE_OUTPUT" "$RELEASE_MATRIX_OUTPUT" "$RELEASE_TIMELINE_OUTPUT" "$LATEST_RELEASE_OUTPUT" <<'RUBY'
require "json"
require "pathname"
require "time"

root_dir, results_root, history_output, comparison_output, methodology_output, timeline_output, release_matrix_output, release_timeline_output, latest_release_output = ARGV

def safe_relative(root_dir, path)
  Pathname.new(path).relative_path_from(Pathname.new(root_dir)).to_s
rescue StandardError
  path
end

def read_json(path)
  JSON.parse(File.read(path))
end

def load_snapshot(root_dir, dir_path, type:, label:)
  report_path = File.join(dir_path, "benchmark-report.json")
  summary_path = File.join(dir_path, "benchmark-summary.md")
  environment_path = File.join(dir_path, "environment.json")
  device_metadata_path = File.join(dir_path, "device-metadata.json")
  metadata_path = File.join(dir_path, "metadata.json")
  release_notes_path = File.join(dir_path, "release-notes-proof.md")
  delta_path = File.join(dir_path, "benchmark-delta.md")
  release_proof_path = File.join(dir_path, "release-proof.md")

  return nil unless File.exist?(report_path) && File.exist?(summary_path) && File.exist?(environment_path)

  report = read_json(report_path)
  environment = read_json(environment_path)
  device_metadata = File.exist?(device_metadata_path) ? read_json(device_metadata_path) : {}
  metadata = File.exist?(metadata_path) ? read_json(metadata_path) : {}
  analysis = report.fetch("analysis")
  results = report.fetch("results")
  sorted_by_time = results.sort_by { |result| result["averageExecutionTime"].to_f }
  fastest = sorted_by_time.first
  slowest = sorted_by_time.last

  {
    label: label,
    type: type,
    dir_path: dir_path,
    dir_relative: safe_relative(root_dir, dir_path),
    report_relative: safe_relative(root_dir, report_path),
    summary_relative: safe_relative(root_dir, summary_path),
    environment_relative: safe_relative(root_dir, environment_path),
    device_metadata_relative: File.exist?(device_metadata_path) ? safe_relative(root_dir, device_metadata_path) : nil,
    metadata_relative: File.exist?(metadata_path) ? safe_relative(root_dir, metadata_path) : nil,
    release_notes_relative: File.exist?(release_notes_path) ? safe_relative(root_dir, release_notes_path) : nil,
    delta_relative: File.exist?(delta_path) ? safe_relative(root_dir, delta_path) : nil,
    release_proof_relative: File.exist?(release_proof_path) ? safe_relative(root_dir, release_proof_path) : nil,
    generated_at: report["generatedAt"],
    archived_at: metadata["archivedAt"],
    git_ref: metadata["gitRef"],
    git_commit: metadata["gitCommit"],
    provenance_kind: metadata.dig("provenance", "sourceKind") || "local-directory",
    provenance_source: metadata.dig("provenance", "sourcePath") || metadata["sourceArtifactsDirectory"],
    export_metadata: metadata["provenance"] && metadata["provenance"]["exportMetadata"],
    profile: report["profile"],
    framework_version: report["frameworkVersion"],
    total_benchmarks: analysis["totalBenchmarks"].to_i,
    performance_score: analysis["performanceScore"].to_f,
    average_execution_time: analysis["averageExecutionTime"].to_f,
    total_memory_usage: analysis["totalMemoryUsage"].to_f,
    platform_family: device_metadata["platformFamily"] || results.first&.fetch("platform", "Unknown"),
    device_name: device_metadata["deviceName"] || environment["hostname"] || "Unknown",
    device_model: device_metadata["deviceModel"] || results.first&.fetch("deviceModel", "Unknown"),
    device_class: device_metadata["deviceClass"] || "Unknown",
    environment_os: environment["operatingSystemVersion"],
    processor_count: environment["processorCount"].to_i,
    physical_memory: environment["physicalMemory"].to_f,
    fastest_name: fastest ? fastest["name"] : nil,
    fastest_time: fastest ? fastest["averageExecutionTime"].to_f : nil,
    slowest_name: slowest ? slowest["name"] : nil,
    slowest_time: slowest ? slowest["averageExecutionTime"].to_f : nil
  }
end

def metric_delta(current, baseline)
  return nil if current.nil? || baseline.nil? || baseline.zero?

  ((current - baseline) / baseline) * 100.0
end

def bytes_to_mb(value)
  value.to_f / (1024 * 1024)
end

def bytes_to_gb(value)
  value.to_f / (1024 * 1024 * 1024)
end

def short_commit(value)
  return "n/a" if value.nil? || value.empty?

  value[0, 12]
end

def preset_name_for(config)
  presets = {
    "quick" => {
      "iterations" => 10,
      "warmupIterations" => 2,
      "measurementInterval" => 0.05,
      "memoryMeasurementEnabled" => true,
      "cpuMeasurementEnabled" => false,
      "batteryMeasurementEnabled" => false
    },
    "default" => {
      "iterations" => 100,
      "warmupIterations" => 10,
      "measurementInterval" => 0.1,
      "memoryMeasurementEnabled" => true,
      "cpuMeasurementEnabled" => true,
      "batteryMeasurementEnabled" => true
    },
    "comprehensive" => {
      "iterations" => 1000,
      "warmupIterations" => 50,
      "measurementInterval" => 0.01,
      "memoryMeasurementEnabled" => true,
      "cpuMeasurementEnabled" => true,
      "batteryMeasurementEnabled" => true
    }
  }

  presets.each do |name, preset|
    return name if preset == config
  end

  "custom"
end

def evidence_time(snapshot)
  Time.parse(snapshot[:archived_at] || snapshot[:generated_at])
rescue StandardError
  Time.at(0)
end

snapshots = []

latest_dir = File.join(results_root, "latest")
latest_snapshot = load_snapshot(root_dir, latest_dir, type: "latest", label: "latest")
snapshots << latest_snapshot if latest_snapshot

releases_dir = File.join(results_root, "releases")
if Dir.exist?(releases_dir)
  Dir.children(releases_dir).sort.each do |child|
    dir_path = File.join(releases_dir, child)
    next unless File.directory?(dir_path)

    snapshot = load_snapshot(root_dir, dir_path, type: "release", label: child)
    snapshots << snapshot if snapshot
  end
end

sorted_snapshots = snapshots.sort_by { |snapshot| evidence_time(snapshot) }.reverse

File.open(history_output, "w") do |file|
  file.puts "# Benchmark History"
  file.puts
  file.puts "Generated from the current benchmark artifact tree."
  file.puts

  if latest_snapshot.nil?
    file.puts "No readable benchmark artifacts were found under `Benchmarks/Results`."
    file.puts
    file.puts "Generate a fresh set with:"
    file.puts
    file.puts "```bash"
    file.puts "bash Scripts/run-benchmarks.sh standard"
    file.puts "```"
  else
    file.puts "## Current Pointer"
    file.puts
    file.puts "- Active pointer: `#{latest_snapshot[:dir_relative]}`"
    file.puts "- Generated at: `#{latest_snapshot[:generated_at]}`"
    file.puts "- Profile: `#{latest_snapshot[:profile]}`"
    file.puts format("- Performance score: `%.2f`", latest_snapshot[:performance_score])
    file.puts format("- Average execution time: `%.4fs`", latest_snapshot[:average_execution_time])
    file.puts
    file.puts "## Snapshot Index"
    file.puts
    file.puts "| Snapshot | Type | Git Ref | Commit | Generated | Archived | Provenance | Score | Avg (s) | Workloads | Source |"
    file.puts "| --- | --- | --- | --- | --- | --- | --- | ---: | ---: | ---: | --- |"

    sorted_snapshots.each do |snapshot|
      archived = snapshot[:archived_at] || "n/a"
      source = "[summary](../../#{snapshot[:summary_relative]})"
      file.puts format(
        "| `%s` | %s | `%s` | `%s` | `%s` | `%s` | `%s` | %.2f | %.4f | %d | %s |",
        snapshot[:label],
        snapshot[:type],
        snapshot[:git_ref] || snapshot[:label],
        short_commit(snapshot[:git_commit]),
        snapshot[:generated_at],
        archived,
        snapshot[:provenance_kind],
        snapshot[:performance_score],
        snapshot[:average_execution_time],
        snapshot[:total_benchmarks],
        source
      )
    end

    file.puts
    file.puts "## Environment Matrix"
    file.puts
    file.puts "| Snapshot | Device Class | Device Name | Device Model | Platform | OS | Provenance | CPU Cores | RAM (GB) | Profile |"
    file.puts "| --- | --- | --- | --- | --- | --- | --- | ---: | ---: | --- |"

    sorted_snapshots.each do |snapshot|
      file.puts format(
        "| `%s` | %s | `%s` | `%s` | `%s` | `%s` | `%s` | %d | %.1f | `%s` |",
        snapshot[:label],
        snapshot[:device_class],
        snapshot[:device_name],
        snapshot[:device_model],
        snapshot[:platform_family] || "Unknown",
        snapshot[:environment_os] || "Unknown",
        snapshot[:provenance_kind],
        snapshot[:processor_count],
        bytes_to_gb(snapshot[:physical_memory]),
        snapshot[:profile]
      )
    end

    file.puts
    file.puts "## Evidence Notes"
    file.puts
    file.puts "- `latest` is a moving pointer and should not be treated as immutable release evidence."
    file.puts "- `releases/<tag-or-timestamp>` is the immutable evidence path for tagged releases."
    file.puts "- Public benchmark claims should prefer archived release bundles over ad-hoc local runs."
  end
end

release_snapshots = sorted_snapshots.select { |snapshot| snapshot[:type] == "release" }
comparison_baseline = release_snapshots.first

File.open(comparison_output, "w") do |file|
  file.puts "# Benchmark Comparison"
  file.puts
  file.puts "This page compares the current `latest` pointer against the most recent immutable release evidence bundle."
  file.puts

  if latest_snapshot.nil?
    file.puts "No readable `latest` benchmark artifact set is available."
    file.puts
    file.puts "Generate one with `bash Scripts/run-benchmarks.sh standard` before using this page."
  elsif comparison_baseline.nil?
    file.puts "No archived release evidence bundle exists yet."
    file.puts
    file.puts "Archive one with:"
    file.puts
    file.puts "```bash"
    file.puts "bash Scripts/archive-benchmark-evidence.sh Benchmarks/Results/latest v1.2.3"
    file.puts "```"
    file.puts
    file.puts "Current `latest` summary:"
    file.puts
    file.puts "- Generated at: `#{latest_snapshot[:generated_at]}`"
    file.puts format("- Performance score: `%.2f`", latest_snapshot[:performance_score])
    file.puts format("- Average execution time: `%.4fs`", latest_snapshot[:average_execution_time])
    file.puts "- Fastest workload: `#{latest_snapshot[:fastest_name]}`"
    file.puts "- Slowest workload: `#{latest_snapshot[:slowest_name]}`"
  else
    score_delta = metric_delta(latest_snapshot[:performance_score], comparison_baseline[:performance_score])
    average_time_delta = metric_delta(latest_snapshot[:average_execution_time], comparison_baseline[:average_execution_time])
    memory_delta = metric_delta(latest_snapshot[:total_memory_usage], comparison_baseline[:total_memory_usage])

    file.puts "## Compared Snapshots"
    file.puts
    file.puts "- Current pointer: `#{latest_snapshot[:dir_relative]}`"
    file.puts "- Baseline release evidence: `#{comparison_baseline[:dir_relative]}`"
    file.puts "- Baseline git ref: `#{comparison_baseline[:git_ref] || comparison_baseline[:label]}`"
    file.puts
    file.puts "## Headline Deltas"
    file.puts
    file.puts "| Metric | Latest | Baseline | Delta |"
    file.puts "| --- | ---: | ---: | ---: |"
    file.puts format("| Performance score | %.2f | %.2f | %+.2f%% |", latest_snapshot[:performance_score], comparison_baseline[:performance_score], score_delta || 0.0)
    file.puts format("| Average execution time (s) | %.4f | %.4f | %+.2f%% |", latest_snapshot[:average_execution_time], comparison_baseline[:average_execution_time], average_time_delta || 0.0)
    file.puts format("| Total memory (MB) | %.1f | %.1f | %+.2f%% |", bytes_to_mb(latest_snapshot[:total_memory_usage]), bytes_to_mb(comparison_baseline[:total_memory_usage]), memory_delta || 0.0)
    file.puts format("| Workloads | %d | %d | %+.0f |", latest_snapshot[:total_benchmarks], comparison_baseline[:total_benchmarks], latest_snapshot[:total_benchmarks] - comparison_baseline[:total_benchmarks])
    file.puts
    file.puts "## Workload Extremes"
    file.puts
    file.puts "- Latest fastest workload: `#{latest_snapshot[:fastest_name]}` (`#{format('%.4fs', latest_snapshot[:fastest_time])}`)"
    file.puts "- Baseline fastest workload: `#{comparison_baseline[:fastest_name]}` (`#{format('%.4fs', comparison_baseline[:fastest_time])}`)"
    file.puts "- Latest slowest workload: `#{latest_snapshot[:slowest_name]}` (`#{format('%.4fs', latest_snapshot[:slowest_time])}`)"
    file.puts "- Baseline slowest workload: `#{comparison_baseline[:slowest_name]}` (`#{format('%.4fs', comparison_baseline[:slowest_time])}`)"
    file.puts
    file.puts "## Evidence Links"
    file.puts
    file.puts "- Latest summary: [benchmark-summary.md](../../#{latest_snapshot[:summary_relative]})"
    file.puts "- Baseline summary: [benchmark-summary.md](../../#{comparison_baseline[:summary_relative]})"
    if comparison_baseline[:metadata_relative]
      file.puts "- Baseline metadata: [metadata.json](../../#{comparison_baseline[:metadata_relative]})"
    end
    file.puts
    file.puts "Interpretation rule: positive score delta is better, negative average-time delta is better, and any comparison across different hardware should be treated as directional rather than definitive."
  end
end

File.open(methodology_output, "w") do |file|
  file.puts "# Benchmark Methodology"
  file.puts
  file.puts "Generated from the current benchmark artifacts and benchmark runner config."
  file.puts

  if latest_snapshot.nil?
    file.puts "No readable benchmark artifact set is available under `Benchmarks/Results/latest`."
    file.puts
    file.puts "Generate one with `bash Scripts/run-benchmarks.sh standard` before using this page."
  else
    latest_report = read_json(File.join(latest_snapshot[:dir_path], "benchmark-report.json"))
    latest_results = latest_report.fetch("results")
    grouped_configs = latest_results.group_by { |result| JSON.generate(result.fetch("config").sort.to_h) }
    file.puts "## Current Run"
    file.puts
    file.puts "- Generated at: `#{latest_snapshot[:generated_at]}`"
    file.puts "- Profile: `#{latest_snapshot[:profile]}`"
    file.puts "- Framework version: `#{latest_snapshot[:framework_version]}`"
    file.puts "- Total workloads: `#{latest_snapshot[:total_benchmarks]}`"
    file.puts format("- Average execution time: `%.4fs`", latest_snapshot[:average_execution_time])
    file.puts format("- Aggregate measured memory: `%.1f MB`", bytes_to_mb(latest_snapshot[:total_memory_usage]))
    file.puts
    file.puts "## Environment"
    file.puts
    file.puts "- Device class: `#{latest_snapshot[:device_class]}`"
    file.puts "- Device name: `#{latest_snapshot[:device_name]}`"
    file.puts "- Device model: `#{latest_snapshot[:device_model]}`"
    file.puts "- Platform: `#{latest_snapshot[:platform_family] || 'Unknown'}`"
    file.puts "- Operating system: `#{latest_snapshot[:environment_os]}`"
    file.puts "- Processor count: `#{latest_snapshot[:processor_count]}`"
    file.puts format("- Physical memory: `%.1f GB`", bytes_to_gb(latest_snapshot[:physical_memory]))
    file.puts
    file.puts "## Config Presets In Use"
    file.puts
    file.puts "| Preset | Workloads | Iterations | Warmup | Interval (s) | CPU | Memory | Battery |"
    file.puts "| --- | ---: | ---: | ---: | ---: | --- | --- | --- |"

    grouped_configs.each_value do |results|
      config = results.first.fetch("config")
      preset_name = preset_name_for(config)
      file.puts format(
        "| `%s` | %d | %d | %d | %.2f | %s | %s | %s |",
        preset_name,
        results.length,
        config["iterations"],
        config["warmupIterations"],
        config["measurementInterval"].to_f,
        config["cpuMeasurementEnabled"],
        config["memoryMeasurementEnabled"],
        config["batteryMeasurementEnabled"]
      )
    end

    file.puts
    file.puts "## Workload Coverage"
    file.puts
    file.puts "| Workload | Preset | Avg (s) | Peak Memory (MB) |"
    file.puts "| --- | --- | ---: | ---: |"

    latest_results.sort_by { |result| result["name"] }.each do |result|
      preset_name = preset_name_for(result.fetch("config"))
      file.puts format(
        "| `%s` | `%s` | %.4f | %.1f |",
        result["name"],
        preset_name,
        result["averageExecutionTime"].to_f,
        bytes_to_mb(result["peakMemoryUsage"])
      )
    end

    file.puts
    file.puts "## Methodology Rules"
    file.puts
    file.puts "- `latest` is a moving pointer for the current validated benchmark run."
    file.puts "- immutable release evidence should come from `Benchmarks/Results/releases/<tag-or-timestamp>`."
    file.puts "- competitor comparisons are only valid when workload shape and hardware class are comparable."
    file.puts "- profile changes change methodology; compare like-for-like profiles only."
    file.puts
    file.puts "## Source Artifacts"
    file.puts
    file.puts "- [benchmark-report.json](../../#{latest_snapshot[:report_relative]})"
    file.puts "- [benchmark-summary.md](../../#{latest_snapshot[:summary_relative]})"
    file.puts "- [environment.json](../../#{latest_snapshot[:environment_relative]})"
    file.puts "- [device-metadata.json](../../#{latest_snapshot[:device_metadata_relative]})" if latest_snapshot[:device_metadata_relative]
    file.puts "- [Benchmark History](Benchmark-History.md)"
    file.puts "- [Benchmark Comparison](Benchmark-Comparison.md)"
  end
end

File.open(timeline_output, "w") do |file|
  file.puts "# Benchmark Timeline"
  file.puts
  file.puts "Chronological benchmark evidence for the active pointer and immutable release bundles."
  file.puts

  if sorted_snapshots.empty?
    file.puts "No readable benchmark artifacts were found under `Benchmarks/Results`."
  else
    chronological = sorted_snapshots.reverse
    file.puts "| Order | Snapshot | Type | Generated | Archived | Score | Avg (s) | Git Ref |"
    file.puts "| ---: | --- | --- | --- | --- | ---: | ---: | --- |"

    chronological.each_with_index do |snapshot, index|
      file.puts format(
        "| %d | `%s` | %s | `%s` | `%s` | %.2f | %.4f | `%s` |",
        index + 1,
        snapshot[:label],
        snapshot[:type],
        snapshot[:generated_at],
        snapshot[:archived_at] || "n/a",
        snapshot[:performance_score],
        snapshot[:average_execution_time],
        snapshot[:git_ref] || snapshot[:label]
      )
    end

    file.puts
    file.puts "## Reading Rule"
    file.puts
    file.puts "- later rows are newer evidence"
    file.puts "- `latest` is a moving pointer, release rows are immutable"
    file.puts "- compare release rows for public changelog claims"
  end
end

File.open(release_matrix_output, "w") do |file|
  file.puts "# Release Benchmark Matrix"
  file.puts
  file.puts "Immutable benchmark evidence bundles only."
  file.puts

  if release_snapshots.empty?
    file.puts "No archived release evidence bundle exists yet."
    file.puts
    file.puts "Create one with `bash Scripts/archive-benchmark-evidence.sh Benchmarks/Results/latest v1.2.3`."
  else
    file.puts "| Release | Archived | Generated | Provenance | Score | Avg (s) | Workloads | Device Class | Device | OS | Summary | Delta |"
    file.puts "| --- | --- | --- | --- | ---: | ---: | ---: | --- | --- | --- | --- | --- |"

    release_snapshots.each do |snapshot|
      delta_link = snapshot[:delta_relative] ? "[delta](../../#{snapshot[:delta_relative]})" : "n/a"

      file.puts format(
        "| `%s` | `%s` | `%s` | `%s` | %.2f | %.4f | %d | `%s` | `%s` | `%s` | [summary](../../%s) | %s |",
        snapshot[:git_ref] || snapshot[:label],
        snapshot[:archived_at] || "n/a",
        snapshot[:generated_at],
        snapshot[:provenance_kind],
        snapshot[:performance_score],
        snapshot[:average_execution_time],
        snapshot[:total_benchmarks],
        snapshot[:device_class],
        snapshot[:device_name],
        snapshot[:environment_os] || "Unknown",
        snapshot[:summary_relative],
        delta_link
      )
    end
  end
end

File.open(release_timeline_output, "w") do |file|
  file.puts "# Release Proof Timeline"
  file.puts
  file.puts "Immutable release evidence bundles in public-facing order."
  file.puts

  if release_snapshots.empty?
    file.puts "No archived release evidence bundle exists yet."
    file.puts
    file.puts "Create one with `bash Scripts/archive-benchmark-evidence.sh Benchmarks/Results/latest v1.2.3`."
  else
    file.puts "| Release | Archived | Score | Avg (s) | Proof | Delta | Notes | Metadata |"
    file.puts "| --- | --- | ---: | ---: | --- | --- | --- | --- |"

    release_snapshots.each do |snapshot|
      proof_link = snapshot[:release_proof_relative] ? "[proof](../../#{snapshot[:release_proof_relative]})" : "n/a"
      delta_link = snapshot[:delta_relative] ? "[delta](../../#{snapshot[:delta_relative]})" : "n/a"
      notes_link = snapshot[:release_notes_relative] ? "[notes](../../#{snapshot[:release_notes_relative]})" : "n/a"
      metadata_link = snapshot[:metadata_relative] ? "[metadata](../../#{snapshot[:metadata_relative]})" : "n/a"

      file.puts format(
        "| `%s` | `%s` | %.2f | %.4f | %s | %s | %s | %s |",
        snapshot[:git_ref] || snapshot[:label],
        snapshot[:archived_at] || "n/a",
        snapshot[:performance_score],
        snapshot[:average_execution_time],
        proof_link,
        delta_link,
        notes_link,
        metadata_link
      )
    end

    file.puts
    file.puts "## Reading Rule"
    file.puts
    file.puts "- use `notes` for release-note-ready proof"
    file.puts "- use `proof` for raw immutable evidence"
    file.puts "- use `delta` for release-to-release performance movement"
  end
end

File.open(latest_release_output, "w") do |file|
  file.puts "# Latest Release Proof"
  file.puts

  latest_release = release_snapshots.first

  if latest_release.nil?
    file.puts "No archived release evidence bundle exists yet."
    file.puts
    file.puts "Archive one with `bash Scripts/archive-benchmark-evidence.sh Benchmarks/Results/latest v1.2.3`."
  else
    file.puts "- Release: `#{latest_release[:git_ref] || latest_release[:label]}`"
    file.puts "- Archived at: `#{latest_release[:archived_at] || "n/a"}`"
    file.puts "- Generated at: `#{latest_release[:generated_at]}`"
    file.puts "- Device class: `#{latest_release[:device_class]}`"
    file.puts "- Device name: `#{latest_release[:device_name]}`"
    file.puts "- Device model: `#{latest_release[:device_model]}`"
    file.puts "- Provenance: `#{latest_release[:provenance_kind]}`"
    file.puts "- Provenance source: `#{latest_release[:provenance_source]}`"
    file.puts format("- Performance score: `%.2f`", latest_release[:performance_score])
    file.puts format("- Average execution time: `%.4fs`", latest_release[:average_execution_time])
    file.puts "- Workloads: `#{latest_release[:total_benchmarks]}`"
    file.puts
    file.puts "## Adoption Snapshot"
    file.puts
    file.puts "- flagship workflow: `Vision -> NLP -> Privacy`"
    file.puts "- first demo guide: [IntelligentCamera](../../Examples/DemoApps/IntelligentCamera/README.md)"
    file.puts "- proof posture: see [Public-Proof-Status.md](Public-Proof-Status.md)"
    file.puts
    file.puts "## Proof Links"
    file.puts
    file.puts "- Summary: [benchmark-summary.md](../../#{latest_release[:summary_relative]})"
    file.puts "- Environment: [environment.json](../../#{latest_release[:environment_relative]})"
    file.puts "- Device metadata: [device-metadata.json](../../#{latest_release[:device_metadata_relative]})" if latest_release[:device_metadata_relative]
    file.puts "- Metadata: [metadata.json](../../#{latest_release[:metadata_relative]})" if latest_release[:metadata_relative]
    file.puts "- Release proof: [release-proof.md](../../#{latest_release[:release_proof_relative]})" if latest_release[:release_proof_relative]
    file.puts "- Release notes proof: [release-notes-proof.md](../../#{latest_release[:release_notes_relative]})" if latest_release[:release_notes_relative]
    file.puts "- Benchmark delta: [benchmark-delta.md](../../#{latest_release[:delta_relative]})" if latest_release[:delta_relative]
    file.puts
    file.puts "Use this page as the first public proof link for the most recent immutable release evidence."
  end
end

puts "Benchmark history generated at #{history_output}"
puts "Benchmark comparison generated at #{comparison_output}"
puts "Benchmark methodology generated at #{methodology_output}"
puts "Benchmark timeline generated at #{timeline_output}"
puts "Release benchmark matrix generated at #{release_matrix_output}"
puts "Release proof timeline generated at #{release_timeline_output}"
puts "Latest release proof generated at #{latest_release_output}"
RUBY
