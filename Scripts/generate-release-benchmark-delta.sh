#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CURRENT_EVIDENCE_DIR="${1:-}"
RESULTS_ROOT="${2:-$ROOT_DIR/Benchmarks/Results}"
OUTPUT_PATH="${3:-}"

if [[ -z "$CURRENT_EVIDENCE_DIR" ]]; then
  echo "Usage: bash Scripts/generate-release-benchmark-delta.sh <current-evidence-dir> [results-root] [output-path]" >&2
  exit 1
fi

if [[ "$CURRENT_EVIDENCE_DIR" != /* ]]; then
  CURRENT_EVIDENCE_DIR="$ROOT_DIR/$CURRENT_EVIDENCE_DIR"
fi

if [[ "$RESULTS_ROOT" != /* ]]; then
  RESULTS_ROOT="$ROOT_DIR/$RESULTS_ROOT"
fi

if [[ -z "$OUTPUT_PATH" ]]; then
  OUTPUT_PATH="$CURRENT_EVIDENCE_DIR/benchmark-delta.md"
elif [[ "$OUTPUT_PATH" != /* ]]; then
  OUTPUT_PATH="$ROOT_DIR/$OUTPUT_PATH"
fi

mkdir -p "$(dirname "$OUTPUT_PATH")"

ruby - "$ROOT_DIR" "$CURRENT_EVIDENCE_DIR" "$RESULTS_ROOT" "$OUTPUT_PATH" <<'RUBY'
require "json"
require "pathname"
require "time"

root_dir, current_dir, results_root, output_path = ARGV

def read_json(path)
  JSON.parse(File.read(path))
end

def relative(root_dir, path)
  Pathname.new(path).relative_path_from(Pathname.new(root_dir)).to_s
rescue StandardError
  path
end

def load_snapshot(root_dir, dir_path)
  report_path = File.join(dir_path, "benchmark-report.json")
  summary_path = File.join(dir_path, "benchmark-summary.md")
  environment_path = File.join(dir_path, "environment.json")
  metadata_path = File.join(dir_path, "metadata.json")

  return nil unless File.exist?(report_path) && File.exist?(summary_path) && File.exist?(environment_path)

  report = read_json(report_path)
  environment = read_json(environment_path)
  metadata = File.exist?(metadata_path) ? read_json(metadata_path) : {}

  {
    dir_path: dir_path,
    dir_relative: relative(root_dir, dir_path),
    report_path: report_path,
    report_relative: relative(root_dir, report_path),
    summary_relative: relative(root_dir, summary_path),
    metadata_relative: File.exist?(metadata_path) ? relative(root_dir, metadata_path) : nil,
    report: report,
    environment: environment,
    metadata: metadata
  }
end

def snapshot_time(snapshot)
  Time.parse(snapshot.fetch(:metadata).fetch("archivedAt", snapshot.fetch(:report).fetch("generatedAt")))
rescue StandardError
  Time.at(0)
end

def metric_delta(current, baseline)
  return nil if baseline.nil? || baseline.to_f.zero?

  ((current.to_f - baseline.to_f) / baseline.to_f) * 100.0
end

def bytes_to_mb(value)
  value.to_f / (1024 * 1024)
end

current_snapshot = load_snapshot(root_dir, current_dir)
abort("Current evidence bundle is missing required benchmark artifacts: #{current_dir}") if current_snapshot.nil?

release_root = File.join(results_root, "releases")
release_snapshots = []

if Dir.exist?(release_root)
  Dir.children(release_root).sort.each do |child|
    dir_path = File.join(release_root, child)
    next unless File.directory?(dir_path)
    next if File.expand_path(dir_path) == File.expand_path(current_dir)

    snapshot = load_snapshot(root_dir, dir_path)
    release_snapshots << snapshot if snapshot
  end
end

baseline_snapshot = release_snapshots.max_by { |snapshot| snapshot_time(snapshot) }

current_results = current_snapshot[:report].fetch("results")
current_analysis = current_snapshot[:report].fetch("analysis")
current_results_by_name = current_results.each_with_object({}) do |result, memo|
  memo[result["name"]] = result
end

File.open(output_path, "w") do |file|
  file.puts "## Benchmark Delta"
  file.puts
  file.puts "- Current evidence bundle: `#{current_snapshot[:dir_relative]}`"
  file.puts "- Current git ref: `#{current_snapshot[:metadata]["gitRef"] || File.basename(current_snapshot[:dir_path])}`"
  file.puts "- Current generated at: `#{current_snapshot[:report]["generatedAt"]}`"
  file.puts

  if baseline_snapshot.nil?
    file.puts "No previous immutable release evidence bundle was found."
    file.puts
    file.puts "The current release should be treated as the initial benchmark baseline."
    file.puts
    file.puts "## Current Summary"
    file.puts
    file.puts "- Performance score: `#{format('%.2f', current_analysis["performanceScore"].to_f)}`"
    file.puts "- Average execution time: `#{format('%.4fs', current_analysis["averageExecutionTime"].to_f)}`"
    file.puts "- Total workloads: `#{current_analysis["totalBenchmarks"]}`"
    file.puts "- Environment: `#{current_snapshot[:environment]["operatingSystemVersion"]}`, `#{current_snapshot[:environment]["processorCount"]}` processors"
    file.puts
    file.puts "- Summary artifact: [benchmark-summary.md](#{File.basename(current_snapshot[:summary_relative])})"
  else
    baseline_results = baseline_snapshot[:report].fetch("results")
    baseline_analysis = baseline_snapshot[:report].fetch("analysis")
    baseline_results_by_name = baseline_results.each_with_object({}) do |result, memo|
      memo[result["name"]] = result
    end

    score_delta = metric_delta(current_analysis["performanceScore"], baseline_analysis["performanceScore"])
    average_time_delta = metric_delta(current_analysis["averageExecutionTime"], baseline_analysis["averageExecutionTime"])
    total_memory_delta = metric_delta(current_analysis["totalMemoryUsage"], baseline_analysis["totalMemoryUsage"])

    shared_names = current_results_by_name.keys & baseline_results_by_name.keys
    performance_deltas = shared_names.map do |name|
      current = current_results_by_name.fetch(name)
      baseline = baseline_results_by_name.fetch(name)

      {
        name: name,
        execution_delta: metric_delta(current["averageExecutionTime"], baseline["averageExecutionTime"]) || 0.0,
        memory_delta: metric_delta(current["peakMemoryUsage"], baseline["peakMemoryUsage"]) || 0.0,
        current_time: current["averageExecutionTime"].to_f,
        baseline_time: baseline["averageExecutionTime"].to_f
      }
    end

    regressions = performance_deltas
      .select { |delta| delta[:execution_delta] > 0.0 }
      .sort_by { |delta| -delta[:execution_delta] }
      .first(5)

    improvements = performance_deltas
      .select { |delta| delta[:execution_delta] < 0.0 }
      .sort_by { |delta| delta[:execution_delta] }
      .first(5)

    added_workloads = current_results_by_name.keys.sort - baseline_results_by_name.keys.sort
    removed_workloads = baseline_results_by_name.keys.sort - current_results_by_name.keys.sort

    file.puts "- Baseline evidence bundle: `#{baseline_snapshot[:dir_relative]}`"
    file.puts "- Baseline git ref: `#{baseline_snapshot[:metadata]["gitRef"] || File.basename(baseline_snapshot[:dir_path])}`"
    file.puts "- Baseline generated at: `#{baseline_snapshot[:report]["generatedAt"]}`"
    file.puts
    file.puts "### Headline Deltas"
    file.puts
    file.puts "| Metric | Current | Baseline | Delta |"
    file.puts "| --- | ---: | ---: | ---: |"
    file.puts format("| Performance score | %.2f | %.2f | %+.2f%% |", current_analysis["performanceScore"].to_f, baseline_analysis["performanceScore"].to_f, score_delta || 0.0)
    file.puts format("| Average execution time (s) | %.4f | %.4f | %+.2f%% |", current_analysis["averageExecutionTime"].to_f, baseline_analysis["averageExecutionTime"].to_f, average_time_delta || 0.0)
    file.puts format("| Total memory (MB) | %.1f | %.1f | %+.2f%% |", bytes_to_mb(current_analysis["totalMemoryUsage"]), bytes_to_mb(baseline_analysis["totalMemoryUsage"]), total_memory_delta || 0.0)
    file.puts format("| Workloads | %d | %d | %+.0f |", current_analysis["totalBenchmarks"].to_i, baseline_analysis["totalBenchmarks"].to_i, current_analysis["totalBenchmarks"].to_i - baseline_analysis["totalBenchmarks"].to_i)
    file.puts

    if improvements.any?
      file.puts "### Top Improvements"
      file.puts
      improvements.each do |delta|
        file.puts format("- `%s`: %.4fs -> %.4fs (%+.2f%%)", delta[:name], delta[:baseline_time], delta[:current_time], delta[:execution_delta])
      end
      file.puts
    end

    if regressions.any?
      file.puts "### Top Regressions"
      file.puts
      regressions.each do |delta|
        file.puts format("- `%s`: %.4fs -> %.4fs (%+.2f%%)", delta[:name], delta[:baseline_time], delta[:current_time], delta[:execution_delta])
      end
      file.puts
    end

    unless added_workloads.empty?
      file.puts "### Added Workloads"
      file.puts
      added_workloads.each { |name| file.puts "- `#{name}`" }
      file.puts
    end

    unless removed_workloads.empty?
      file.puts "### Removed Workloads"
      file.puts
      removed_workloads.each { |name| file.puts "- `#{name}`" }
      file.puts
    end

    file.puts "### Evidence Links"
    file.puts
    file.puts "- Current summary: [benchmark-summary.md](#{File.basename(current_snapshot[:summary_relative])})"
    file.puts "- Baseline summary: [`#{baseline_snapshot[:summary_relative]}`](../../#{baseline_snapshot[:summary_relative]})"
    if baseline_snapshot[:metadata_relative]
      file.puts "- Baseline metadata: [`#{baseline_snapshot[:metadata_relative]}`](../../#{baseline_snapshot[:metadata_relative]})"
    end
    file.puts
    file.puts "Interpretation rule: negative execution-time delta is better. Cross-device comparisons are directional only."
  end
end

puts "Benchmark delta generated at #{output_path}"
RUBY
