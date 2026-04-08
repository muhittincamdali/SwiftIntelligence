#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RESULTS_ROOT="${1:-$ROOT_DIR/Benchmarks/Results}"

if [[ "$RESULTS_ROOT" != /* ]]; then
  RESULTS_ROOT="$ROOT_DIR/$RESULTS_ROOT"
fi

ruby - "$RESULTS_ROOT" <<'RUBY'
require "json"

results_root = ARGV[0]
releases_root = File.join(results_root, "releases")

unless Dir.exist?(releases_root)
  puts "Release provenance validation skipped: no releases directory."
  exit 0
end

errors = []
validated = 0

Dir.children(releases_root).sort.each do |child|
  bundle_dir = File.join(releases_root, child)
  next unless File.directory?(bundle_dir)

  metadata_path = File.join(bundle_dir, "metadata.json")
  if !File.exist?(metadata_path)
    errors << "Missing metadata.json in #{bundle_dir}"
    next
  end

  metadata = JSON.parse(File.read(metadata_path))
  provenance = metadata["provenance"]

  if provenance.nil?
    errors << "Missing provenance object in #{metadata_path}"
    next
  end

  source_kind = provenance["sourceKind"]
  source_path = provenance["sourcePath"]

  errors << "Missing provenance.sourceKind in #{metadata_path}" if source_kind.to_s.empty?
  errors << "Missing provenance.sourcePath in #{metadata_path}" if source_path.to_s.empty?

  if source_kind == "archive-import"
    export_metadata = provenance["exportMetadata"]
    if !export_metadata.is_a?(Hash)
      errors << "Missing provenance.exportMetadata for archive-import bundle in #{metadata_path}"
    else
      errors << "Missing exportMetadata.archiveRoot in #{metadata_path}" if export_metadata["archiveRoot"].to_s.empty?
      errors << "Missing exportMetadata.exportedAt in #{metadata_path}" if export_metadata["exportedAt"].to_s.empty?
    end
  end

  validated += 1
end

if errors.empty?
  puts "Release provenance validated for #{validated} bundle(s)."
  exit 0
end

warn "Release provenance validation failed:"
errors.each { |error| warn "- #{error}" }
exit 1
RUBY
