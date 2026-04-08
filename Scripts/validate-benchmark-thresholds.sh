#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CURRENT_RESULTS_DIR="${1:-$ROOT_DIR/Benchmarks/Results/latest}"
RESULTS_ROOT="${2:-$ROOT_DIR/Benchmarks/Results}"
THRESHOLDS_PATH="${3:-$ROOT_DIR/Benchmarks/benchmark-thresholds.json}"

if [[ "$CURRENT_RESULTS_DIR" != /* ]]; then
  CURRENT_RESULTS_DIR="$ROOT_DIR/$CURRENT_RESULTS_DIR"
fi

if [[ "$RESULTS_ROOT" != /* ]]; then
  RESULTS_ROOT="$ROOT_DIR/$RESULTS_ROOT"
fi

if [[ "$THRESHOLDS_PATH" != /* ]]; then
  THRESHOLDS_PATH="$ROOT_DIR/$THRESHOLDS_PATH"
fi

ruby - "$ROOT_DIR" "$CURRENT_RESULTS_DIR" "$RESULTS_ROOT" "$THRESHOLDS_PATH" <<'RUBY'
require "json"
require "pathname"
require "time"

root_dir, current_results_dir, results_root, thresholds_path = ARGV

def read_json(path)
  JSON.parse(File.read(path))
end

def load_snapshot(dir_path)
  report_path = File.join(dir_path, "benchmark-report.json")
  metadata_path = File.join(dir_path, "metadata.json")
  return nil unless File.exist?(report_path)

  {
    dir_path: dir_path,
    report: read_json(report_path),
    metadata: File.exist?(metadata_path) ? read_json(metadata_path) : {}
  }
end

def snapshot_time(snapshot)
  metadata = snapshot.fetch(:metadata)
  report = snapshot.fetch(:report)
  Time.parse(metadata["archivedAt"] || report["generatedAt"])
rescue StandardError
  Time.at(0)
end

def percent_change(current, baseline)
  return 0.0 if baseline.to_f.zero?
  ((current.to_f - baseline.to_f) / baseline.to_f) * 100.0
end

abort("Missing threshold config: #{thresholds_path}") unless File.exist?(thresholds_path)

thresholds = read_json(thresholds_path)
current_snapshot = load_snapshot(current_results_dir)
abort("Missing current benchmark report in #{current_results_dir}") if current_snapshot.nil?

release_root = File.join(results_root, "releases")
baseline_candidates = []

if Dir.exist?(release_root)
  Dir.children(release_root).sort.each do |child|
    dir_path = File.join(release_root, child)
    next unless File.directory?(dir_path)
    next if File.expand_path(dir_path) == File.expand_path(current_results_dir)

    snapshot = load_snapshot(dir_path)
    baseline_candidates << snapshot if snapshot
  end
end

baseline_snapshot = baseline_candidates.max_by { |snapshot| snapshot_time(snapshot) }

if baseline_snapshot.nil?
  puts "No archived release evidence bundle found. Threshold gate skipped for initial baseline."
  exit 0
end

current_report = current_snapshot.fetch(:report)
baseline_report = baseline_snapshot.fetch(:report)

current_analysis = current_report.fetch("analysis")
baseline_analysis = baseline_report.fetch("analysis")

score_drop = percent_change(current_analysis["performanceScore"], baseline_analysis["performanceScore"]) * -1.0
avg_execution_increase = percent_change(current_analysis["averageExecutionTime"], baseline_analysis["averageExecutionTime"])
total_memory_increase = percent_change(current_analysis["totalMemoryUsage"], baseline_analysis["totalMemoryUsage"])

failures = []

max_score_drop = thresholds.fetch("maxPerformanceScoreDropPercent").to_f
max_avg_time_increase = thresholds.fetch("maxAverageExecutionTimeIncreasePercent").to_f
max_total_memory_increase = thresholds.fetch("maxTotalMemoryIncreasePercent").to_f
max_workload_time_increase = thresholds.fetch("maxPerWorkloadExecutionTimeIncreasePercent").to_f
max_workload_memory_increase = thresholds.fetch("maxPerWorkloadPeakMemoryIncreasePercent").to_f
max_regressed_count = thresholds.fetch("maxRegressedWorkloadCount").to_i

failures << format("performance score dropped by %.2f%% (limit %.2f%%)", score_drop, max_score_drop) if score_drop > max_score_drop
failures << format("average execution time increased by %.2f%% (limit %.2f%%)", avg_execution_increase, max_avg_time_increase) if avg_execution_increase > max_avg_time_increase
failures << format("total memory increased by %.2f%% (limit %.2f%%)", total_memory_increase, max_total_memory_increase) if total_memory_increase > max_total_memory_increase

current_results = current_report.fetch("results").each_with_object({}) { |item, memo| memo[item.fetch("name")] = item }
baseline_results = baseline_report.fetch("results").each_with_object({}) { |item, memo| memo[item.fetch("name")] = item }

shared_names = current_results.keys & baseline_results.keys
regressed_workloads = []

shared_names.sort.each do |name|
  current = current_results.fetch(name)
  baseline = baseline_results.fetch(name)

  execution_increase = percent_change(current["averageExecutionTime"], baseline["averageExecutionTime"])
  memory_increase = percent_change(current["peakMemoryUsage"], baseline["peakMemoryUsage"])

  next unless execution_increase > max_workload_time_increase || memory_increase > max_workload_memory_increase

  regressed_workloads << {
    name: name,
    execution_increase: execution_increase,
    memory_increase: memory_increase
  }
end

if regressed_workloads.length > max_regressed_count
  failures << "regressed workloads count #{regressed_workloads.length} exceeds limit #{max_regressed_count}"
end

regressed_workloads.each do |entry|
  if entry[:execution_increase] > max_workload_time_increase
    failures << format(
      "workload %s execution time increased by %.2f%% (limit %.2f%%)",
      entry[:name],
      entry[:execution_increase],
      max_workload_time_increase
    )
  end

  if entry[:memory_increase] > max_workload_memory_increase
    failures << format(
      "workload %s peak memory increased by %.2f%% (limit %.2f%%)",
      entry[:name],
      entry[:memory_increase],
      max_workload_memory_increase
    )
  end
end

if failures.any?
  warn "Benchmark regression threshold validation failed against #{baseline_snapshot.dig(:metadata, "gitRef") || File.basename(baseline_snapshot[:dir_path])}:"
  failures.each { |failure| warn "- #{failure}" }
  exit 1
end

puts "Benchmark regression thresholds validated against #{baseline_snapshot.dig(:metadata, "gitRef") || File.basename(baseline_snapshot[:dir_path])}."
RUBY
