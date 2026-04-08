#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR="${1:-Benchmarks/Results/latest}"
SNAPSHOT_NAME="${2:-$(date -u +"%Y%m%dT%H%M%SZ")}"

if [[ "$SOURCE_DIR" != /* ]]; then
  SOURCE_DIR="$ROOT_DIR/$SOURCE_DIR"
fi

SAFE_NAME="$(printf '%s' "$SNAPSHOT_NAME" | tr '/ ' '--' | tr -cd 'A-Za-z0-9._-')"

if [[ -z "$SAFE_NAME" ]]; then
  echo "Snapshot name resolved to an empty value." >&2
  exit 1
fi

bash "$ROOT_DIR/Scripts/generate-device-metadata.sh" "$SOURCE_DIR" >/dev/null
bash "$ROOT_DIR/Scripts/generate-artifact-manifest.sh" "$SOURCE_DIR" >/dev/null

DEST_RELATIVE_DIR="Benchmarks/Results/releases/$SAFE_NAME"
DEST_DIR="$ROOT_DIR/$DEST_RELATIVE_DIR"

required_artifacts=(
  "benchmark-report.json"
  "benchmark-summary.md"
  "environment.json"
  "device-metadata.json"
)

for artifact in "${required_artifacts[@]}"; do
  if [[ ! -f "$SOURCE_DIR/$artifact" ]]; then
    echo "Missing benchmark artifact: $SOURCE_DIR/$artifact" >&2
    exit 1
  fi
done

rm -rf "$DEST_DIR"
mkdir -p "$DEST_DIR"

for artifact in "${required_artifacts[@]}"; do
  cp "$SOURCE_DIR/$artifact" "$DEST_DIR/$artifact"
done

GIT_COMMIT="${GITHUB_SHA:-$(git -C "$ROOT_DIR" rev-parse HEAD)}"
GIT_REF="${GITHUB_REF_NAME:-$SAFE_NAME}"
ARCHIVED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
SOURCE_RELATIVE_DIR="${SOURCE_DIR#$ROOT_DIR/}"
EVIDENCE_SOURCE_KIND="${SI_BENCHMARK_EVIDENCE_SOURCE_KIND:-local-directory}"
EVIDENCE_SOURCE_PATH="${SI_BENCHMARK_EVIDENCE_SOURCE_PATH:-$SOURCE_RELATIVE_DIR}"
EXPORT_METADATA_JSON="${SI_BENCHMARK_EXPORT_METADATA_JSON:-}"

ruby - "$DEST_DIR" "$DEST_RELATIVE_DIR" "$SAFE_NAME" "$GIT_REF" "$GIT_COMMIT" "$ARCHIVED_AT" "$SOURCE_RELATIVE_DIR" "$EVIDENCE_SOURCE_KIND" "$EVIDENCE_SOURCE_PATH" "$EXPORT_METADATA_JSON" <<'RUBY'
require "json"

dest_dir, dest_relative_dir, snapshot_name, git_ref, git_commit, archived_at, source_relative_dir, evidence_source_kind, evidence_source_path, export_metadata_json = ARGV

report = JSON.parse(File.read(File.join(dest_dir, "benchmark-report.json")))
environment = JSON.parse(File.read(File.join(dest_dir, "environment.json")))
device_metadata = JSON.parse(File.read(File.join(dest_dir, "device-metadata.json")))
results = report.fetch("results")
analysis = report.fetch("analysis")

sorted_by_time = results.sort_by { |result| result["averageExecutionTime"].to_f }
fastest = sorted_by_time.first
slowest = sorted_by_time.last

bytes_to_gb = ->(value) { value.to_f / (1024 * 1024 * 1024) }

export_metadata = if export_metadata_json.nil? || export_metadata_json.empty?
  nil
else
  JSON.parse(export_metadata_json)
end

provenance = {
  sourceKind: evidence_source_kind,
  sourcePath: evidence_source_path
}
provenance[:exportMetadata] = export_metadata if export_metadata

metadata = {
  archivedAt: archived_at,
  snapshotName: snapshot_name,
  gitRef: git_ref,
  gitCommit: git_commit,
  sourceArtifactsDirectory: source_relative_dir,
  archivedArtifactsDirectory: dest_relative_dir,
  provenance: provenance,
  profile: report["profile"],
  generatedAt: report["generatedAt"],
  deviceMetadata: device_metadata
}

File.write(
  File.join(dest_dir, "metadata.json"),
  JSON.pretty_generate(metadata) + "\n"
)

File.open(File.join(dest_dir, "release-proof.md"), "w") do |file|
  file.puts "## Benchmark Evidence"
  file.puts
  file.puts "- Evidence bundle: `#{dest_relative_dir}`"
  file.puts "- Snapshot name: `#{snapshot_name}`"
  file.puts "- Git ref: `#{git_ref}`"
  file.puts "- Git commit: `#{git_commit}`"
  file.puts "- Benchmark profile: `#{report['profile']}`"
  file.puts "- Benchmark run generated at: `#{report['generatedAt']}`"
  file.puts "- Evidence archived at: `#{archived_at}`"
  file.puts "- Evidence source kind: `#{evidence_source_kind}`"
  file.puts "- Evidence source path: `#{evidence_source_path}`"
  file.puts "- Device class: `#{device_metadata['deviceClass']}`"
  file.puts "- Device name: `#{device_metadata['deviceName']}`"
  file.puts "- Device model: `#{device_metadata['deviceModel']}`"
  file.puts "- Platform family: `#{device_metadata['platformFamily']}`"
  if export_metadata
    file.puts "- Exported at: `#{export_metadata['exportedAt']}`" if export_metadata["exportedAt"]
    file.puts "- Export archive root: `#{export_metadata['archiveRoot']}`" if export_metadata["archiveRoot"]
  end
  file.puts "- Total workloads: `#{analysis['totalBenchmarks']}`"
  file.puts format("- Performance score: `%.2f`", analysis["performanceScore"].to_f)
  file.puts format("- Average execution time: `%.4fs`", analysis["averageExecutionTime"].to_f)
  file.puts format("- Environment: `%s`, `%s` processors, `%.1f GB` RAM", environment["operatingSystemVersion"], environment["processorCount"], bytes_to_gb.call(environment["physicalMemory"]))
  file.puts format("- Fastest workload: `%s` (`%.4fs`)", fastest["name"], fastest["averageExecutionTime"].to_f)
  file.puts format("- Slowest workload: `%s` (`%.4fs`)", slowest["name"], slowest["averageExecutionTime"].to_f)
  file.puts
  file.puts "Attached benchmark assets were copied from this immutable evidence bundle."
end
RUBY

bash "$ROOT_DIR/Scripts/generate-release-benchmark-delta.sh" "$DEST_DIR" "$ROOT_DIR/Benchmarks/Results" "$DEST_DIR/benchmark-delta.md" >/dev/null
bash "$ROOT_DIR/Scripts/generate-release-notes-proof.sh" "$DEST_DIR" "$DEST_DIR/release-notes-proof.md" >/dev/null

bash "$ROOT_DIR/Scripts/hydrate-release-evidence-assets.sh" "$DEST_DIR" >/dev/null

bash "$ROOT_DIR/Scripts/generate-artifact-manifest.sh" "$DEST_DIR" "$DEST_DIR/artifact-manifest.json" "$DEST_DIR/checksums.txt" >/dev/null

echo "Archived benchmark evidence to $DEST_RELATIVE_DIR" >&2
printf '%s\n' "$DEST_RELATIVE_DIR"
