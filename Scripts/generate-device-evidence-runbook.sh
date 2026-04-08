#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLAN_PATH="${1:-$ROOT_DIR/Documentation/Generated/Device-Evidence-Plan.md}"
MATRIX_PATH="${2:-$ROOT_DIR/Documentation/Generated/Device-Coverage-Matrix.md}"
OUTPUT_PATH="${3:-$ROOT_DIR/Documentation/Generated/Device-Evidence-Runbook.md}"

if [[ "$PLAN_PATH" != /* ]]; then
  PLAN_PATH="$ROOT_DIR/$PLAN_PATH"
fi

if [[ "$MATRIX_PATH" != /* ]]; then
  MATRIX_PATH="$ROOT_DIR/$MATRIX_PATH"
fi

if [[ "$OUTPUT_PATH" != /* ]]; then
  OUTPUT_PATH="$ROOT_DIR/$OUTPUT_PATH"
fi

mkdir -p "$(dirname "$OUTPUT_PATH")"

ruby - "$PLAN_PATH" "$MATRIX_PATH" "$OUTPUT_PATH" <<'RUBY'
plan_path, matrix_path, output_path = ARGV

abort("Missing device evidence plan: #{plan_path}") unless File.exist?(plan_path)
abort("Missing device coverage matrix: #{matrix_path}") unless File.exist?(matrix_path)

plan = File.read(plan_path)
matrix = File.read(matrix_path)

missing_classes = begin
  explicit = matrix[/Missing required release device classes: `([^`]+)`/, 1]
  explicit ? explicit.split(",").map(&:strip).reject(&:empty?) : []
end

capture_blocks = plan.scan(/## Wave \d+: ([^\n]+)\n.*?```bash\n(.*?)```/m).map do |title, command|
  { title: title.strip, command: command.rstrip }
end

File.open(output_path, "w") do |file|
  file.puts "# Device Evidence Runbook"
  file.puts
  file.puts "Generated maintainer checklist for collecting or importing missing benchmark device evidence."
  file.puts
  file.puts "## Current Gap"
  file.puts
  file.puts "- Missing required release device classes: `#{missing_classes.join(', ')}`"
  file.puts "- Source plan: [Device-Evidence-Plan.md](Device-Evidence-Plan.md)"
  file.puts "- Source matrix: [Device-Coverage-Matrix.md](Device-Coverage-Matrix.md)"
  file.puts "- Public intake form: [../../.github/ISSUE_TEMPLATE/device_evidence.yml](../../.github/ISSUE_TEMPLATE/device_evidence.yml)"
  file.puts
  file.puts "## Path A: Capture In This Repo"
  file.puts
  file.puts "1. Connect the target Apple device and confirm the benchmark build can run there."
  file.puts "2. Use `Scripts/run-benchmarks-for-device.sh` with the normalized device metadata from the generated plan."
  file.puts "3. Regenerate docs with `bash Scripts/build-docs.sh`."
  file.puts "4. Run `bash Scripts/prepare-release.sh`."
  file.puts "5. Confirm `Device-Coverage-Matrix.md` and `Benchmark-Readiness.md` changed in the expected direction."
  file.puts "6. If the bundle still needs maintainer review, open the `Device Evidence Submission` issue and include the snapshot name plus device metadata."
  file.puts
  file.puts "## Path B: Import External Evidence"
  file.puts
  file.puts "1. Export `benchmark-report.json`, `benchmark-summary.md`, and `environment.json` from the source machine, or package a validated artifact set with `Scripts/export-benchmark-evidence.sh`."
  file.puts "2. Import them with `Scripts/import-benchmark-evidence.sh` and normalized device metadata."
  file.puts "3. Regenerate docs with `bash Scripts/build-docs.sh`."
  file.puts "4. Run `bash Scripts/prepare-release.sh`."
  file.puts "5. Confirm the imported bundle appears in `Release-Benchmark-Matrix.md` and `Device-Coverage-Matrix.md`."
  file.puts "6. If review or follow-up hardware work is still needed, open the `Device Evidence Submission` issue and attach the archive path."
  file.puts
  file.puts "## Path C: Close The Full Pending Wave"
  file.puts
  file.puts "When all pending archives are available, import them together:"
  file.puts
  file.puts "```bash"
  file.puts "bash Scripts/complete-device-evidence-wave.sh \\"
  missing_classes.each do |device_class|
    slug = device_class.downcase
    snapshot_slug = slug == "iphone" ? "iphone" : slug
    file.puts "  --archive #{device_class}=/absolute/path/to/#{slug}-benchmark-export.tar.gz \\"
    file.puts "  --snapshot #{device_class}=#{snapshot_slug}-baseline-<tag-or-date> \\"
  end
  file.puts "  --skip-prepare-release"
  file.puts "```"
  file.puts
  file.puts "Remove `--skip-prepare-release` to run the full release validation flow immediately after the final import."
  file.puts
  file.puts "## Capture Commands"
  file.puts

  if capture_blocks.empty?
    file.puts "No capture commands were found in the current device evidence plan."
  else
    capture_blocks.each_with_index do |block, index|
      file.puts "### Command #{index + 1}: #{block[:title]}"
      file.puts
      file.puts "```bash"
      file.puts block[:command]
      file.puts "```"
      file.puts
    end
  end

  file.puts "## Import Template"
  file.puts
  file.puts "Package a validated artifact set for transfer:"
  file.puts
  file.puts "```bash"
  file.puts "bash Scripts/export-benchmark-evidence.sh \\"
  file.puts "  Benchmarks/Results/latest \\"
  file.puts "  /absolute/path/to/benchmark-export.tar.gz"
  file.puts "```"
  file.puts
  file.puts "Or emit the export archive directly during device capture:"
  file.puts
  file.puts "```bash"
  file.puts "bash Scripts/run-benchmarks-for-device.sh \\"
  file.puts "  --profile standard \\"
  file.puts "  --output-dir Benchmarks/Results/device-run \\"
  file.puts "  --device-name \"<device name>\" \\"
  file.puts "  --device-model \"<device model>\" \\"
  file.puts "  --device-class <Mac|iPhone|iPad|visionOS|tvOS|watchOS> \\"
  file.puts "  --platform-family <macOS|iOS|iPadOS|visionOS|tvOS|watchOS> \\"
  file.puts "  --soc \"<SoC label>\" \\"
  file.puts "  --export-archive /absolute/path/to/benchmark-export.tar.gz"
  file.puts "```"
  file.puts
  file.puts "Then import the archive directly on the destination repo:"
  file.puts
  file.puts "```bash"
  file.puts "bash Scripts/import-benchmark-evidence.sh \\"
  file.puts "  --device-name \"<device name>\" \\"
  file.puts "  --device-model \"<device model>\" \\"
  file.puts "  --device-class <Mac|iPhone|iPad|visionOS|tvOS|watchOS> \\"
  file.puts "  --platform-family <macOS|iOS|iPadOS|visionOS|tvOS|watchOS> \\"
  file.puts "  --soc \"<SoC label>\" \\"
  file.puts "  /absolute/path/to/benchmark-export.tar.gz \\"
  file.puts "  <snapshot-name>"
  file.puts "```"
  file.puts
  file.puts "## Verification Checklist"
  file.puts
  file.puts "- `bash Scripts/validate-benchmarks.sh <profile> <artifact-dir>` passes."
  file.puts "- `bash Scripts/validate-device-evidence.sh` passes."
  file.puts "- `Documentation/Generated/Device-Coverage-Matrix.md` shows the new device class."
  file.puts "- `Documentation/Generated/Benchmark-Readiness.md` moves toward `ready`."
  file.puts "- `bash Scripts/prepare-release.sh` passes without regressions."
  file.puts "- Any remaining maintainer action is tracked through the `Device Evidence Submission` issue form."
end

puts "Device evidence runbook generated at #{output_path}"
RUBY
