#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EVIDENCE_DIR="${1:-}"
OUTPUT_PATH="${2:-}"

if [[ -z "$EVIDENCE_DIR" ]]; then
  echo "Usage: bash Scripts/generate-release-notes-proof.sh <evidence-dir> [output-path]" >&2
  exit 1
fi

if [[ "$EVIDENCE_DIR" != /* ]]; then
  EVIDENCE_DIR="$ROOT_DIR/$EVIDENCE_DIR"
fi

if [[ -z "$OUTPUT_PATH" ]]; then
  OUTPUT_PATH="$EVIDENCE_DIR/release-notes-proof.md"
elif [[ "$OUTPUT_PATH" != /* ]]; then
  OUTPUT_PATH="$ROOT_DIR/$OUTPUT_PATH"
fi

mkdir -p "$(dirname "$OUTPUT_PATH")"

ruby - "$ROOT_DIR" "$EVIDENCE_DIR" "$OUTPUT_PATH" <<'RUBY'
require "json"
require "pathname"

root_dir, evidence_dir, output_path = ARGV

def read_json(path)
  JSON.parse(File.read(path))
end

def safe_relative(root_dir, path)
  Pathname.new(path).relative_path_from(Pathname.new(root_dir)).to_s
rescue StandardError
  path
end

report_path = File.join(evidence_dir, "benchmark-report.json")
summary_path = File.join(evidence_dir, "benchmark-summary.md")
environment_path = File.join(evidence_dir, "environment.json")
metadata_path = File.join(evidence_dir, "metadata.json")
proof_path = File.join(evidence_dir, "release-proof.md")
delta_path = File.join(evidence_dir, "benchmark-delta.md")
blockers_path = File.join(evidence_dir, "release-blockers.md")
public_proof_path = File.join(evidence_dir, "public-proof-status.md")
handoff_md_path = File.join(evidence_dir, "device-evidence-handoff.md")
handoff_archive_path = File.join(evidence_dir, "device-evidence-handoff.tar.gz")
flagship_demo_pack_path = File.join(evidence_dir, "flagship-demo-pack.md")

required_paths = [report_path, summary_path, environment_path, metadata_path, proof_path, delta_path]
missing_path = required_paths.find { |path| !File.exist?(path) }
abort("Missing required release evidence artifact: #{missing_path}") if missing_path

report = read_json(report_path)
environment = read_json(environment_path)
metadata = read_json(metadata_path)
analysis = report.fetch("analysis")

File.open(output_path, "w") do |file|
  file.puts "## Release Proof"
  file.puts
  file.puts "- Release: `#{metadata["gitRef"] || metadata["snapshotName"]}`"
  file.puts "- Evidence bundle: `#{safe_relative(root_dir, evidence_dir)}`"
  file.puts "- Git commit: `#{metadata["gitCommit"]}`"
  file.puts "- Benchmark profile: `#{report["profile"]}`"
  file.puts "- Benchmark run generated at: `#{report["generatedAt"]}`"
  file.puts "- Evidence archived at: `#{metadata["archivedAt"]}`"
  file.puts format("- Performance score: `%.2f`", analysis["performanceScore"].to_f)
  file.puts format("- Average execution time: `%.4fs`", analysis["averageExecutionTime"].to_f)
  file.puts "- Environment: `#{environment["operatingSystemVersion"]}`, `#{environment["processorCount"]}` processors"
  file.puts
  file.puts "## Adoption Snapshot"
  file.puts
  file.puts "- strongest first-run flow: `Vision -> NLP -> Privacy`"
  file.puts "- flagship demo validation: `bash Scripts/validate-flagship-demo.sh`"
  file.puts "- repo-native flagship media is currently `not-published` until real screenshot/video assets are checked in" unless File.exist?(flagship_demo_pack_path)
  file.puts "- public proof envelope is carried in `public-proof-status.md` when bundled"
  file.puts
  file.puts "## Validation Gate"
  file.puts
  file.puts "- `swift build -c release`"
  file.puts "- `bash Scripts/validate-flagship-demo.sh`"
  file.puts "- `bash Scripts/validate-examples.sh`"
  file.puts "- `swift test`"
  file.puts "- `bash Scripts/run-benchmarks.sh standard Benchmarks/Results/latest`"
  file.puts "- immutable benchmark evidence archived under `#{safe_relative(root_dir, evidence_dir)}`"
  file.puts
  file.puts "## Attached Artifacts"
  file.puts
  file.puts "- [benchmark-summary.md](benchmark-summary.md)"
  file.puts "- [benchmark-report.json](benchmark-report.json)"
  file.puts "- [environment.json](environment.json)"
  file.puts "- [metadata.json](metadata.json)"
  file.puts "- [release-proof.md](release-proof.md)"
  file.puts "- [benchmark-delta.md](benchmark-delta.md)"
  file.puts "- [release-blockers.md](release-blockers.md)" if File.exist?(blockers_path)
  file.puts "- [public-proof-status.md](public-proof-status.md)" if File.exist?(public_proof_path)
  file.puts "- [device-evidence-handoff.md](device-evidence-handoff.md)" if File.exist?(handoff_md_path)
  file.puts "- `device-evidence-handoff.tar.gz`" if File.exist?(handoff_archive_path)
  file.puts
  file.puts File.read(proof_path).strip
  file.puts
  file.puts File.read(delta_path).strip
  file.puts
  if File.exist?(blockers_path)
    file.puts File.read(blockers_path).strip
    file.puts
  end
  if File.exist?(public_proof_path)
    file.puts File.read(public_proof_path).strip
    file.puts
  end
  if File.exist?(handoff_md_path)
    file.puts File.read(handoff_md_path).strip
    file.puts
  end
end

puts "Release notes proof generated at #{output_path}"
RUBY
