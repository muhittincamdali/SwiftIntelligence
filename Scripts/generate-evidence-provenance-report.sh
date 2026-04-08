#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RESULTS_ROOT="${1:-$ROOT_DIR/Benchmarks/Results}"
OUTPUT_PATH="${2:-$ROOT_DIR/Documentation/Generated/Evidence-Provenance.md}"

if [[ "$RESULTS_ROOT" != /* ]]; then
  RESULTS_ROOT="$ROOT_DIR/$RESULTS_ROOT"
fi

if [[ "$OUTPUT_PATH" != /* ]]; then
  OUTPUT_PATH="$ROOT_DIR/$OUTPUT_PATH"
fi

mkdir -p "$(dirname "$OUTPUT_PATH")"

ruby - "$ROOT_DIR" "$RESULTS_ROOT" "$OUTPUT_PATH" <<'RUBY'
require "json"
require "pathname"

root_dir, results_root, output_path = ARGV
releases_root = File.join(results_root, "releases")

def relative(root_dir, path)
  Pathname.new(path).relative_path_from(Pathname.new(root_dir)).to_s
rescue StandardError
  path
end

rows = []

if Dir.exist?(releases_root)
  Dir.children(releases_root).sort.each do |child|
    bundle_dir = File.join(releases_root, child)
    next unless File.directory?(bundle_dir)

    metadata_path = File.join(bundle_dir, "metadata.json")
    next unless File.exist?(metadata_path)

    metadata = JSON.parse(File.read(metadata_path))
    provenance = metadata["provenance"] || {}
    export_metadata = provenance["exportMetadata"] || {}

    rows << {
      release: metadata["gitRef"] || metadata["snapshotName"] || child,
      archived_at: metadata["archivedAt"] || "n/a",
      snapshot: metadata["snapshotName"] || child,
      source_kind: provenance["sourceKind"] || "unknown",
      source_path: provenance["sourcePath"] || metadata["sourceArtifactsDirectory"] || "unknown",
      export_root: export_metadata["archiveRoot"] || "n/a",
      exported_at: export_metadata["exportedAt"] || "n/a",
      handoff_archive: File.exist?(File.join(bundle_dir, "device-evidence-handoff.tar.gz")) ? "present" : "absent",
      public_proof: File.exist?(File.join(bundle_dir, "public-proof-status.json")) ? "present" : "absent",
      metadata_relative: relative(root_dir, metadata_path)
    }
  end
end

File.open(output_path, "w") do |file|
  file.puts "# Evidence Provenance"
  file.puts
  file.puts "Generated provenance inventory for immutable benchmark evidence bundles."
  file.puts

  if rows.empty?
    file.puts "No archived release evidence bundle exists yet."
    file.puts
    file.puts "Create one with `bash Scripts/archive-benchmark-evidence.sh Benchmarks/Results/latest v1.2.3`."
  else
    file.puts "| Release | Snapshot | Archived | Provenance | Source Path | Export Root | Exported At | Public Proof | Handoff Archive | Metadata |"
    file.puts "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |"

    rows.sort_by { |row| row[:archived_at] }.reverse.each do |row|
      file.puts format(
        "| `%s` | `%s` | `%s` | `%s` | `%s` | `%s` | `%s` | `%s` | `%s` | [metadata](../../%s) |",
        row[:release],
        row[:snapshot],
        row[:archived_at],
        row[:source_kind],
        row[:source_path],
        row[:export_root],
        row[:exported_at],
        row[:public_proof],
        row[:handoff_archive],
        row[:metadata_relative]
      )
    end

    file.puts
    file.puts "## Reading Rule"
    file.puts
    file.puts "- `local-directory` means the bundle was archived directly from a local artifact directory."
    file.puts "- `directory-import` means a pre-extracted external artifact directory was imported."
    file.puts "- `archive-import` means a packaged export archive was imported."
  end
end

puts "Evidence provenance report generated at #{output_path}"
RUBY
