#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLAN_PATH="${1:-$ROOT_DIR/Documentation/Generated/Device-Evidence-Plan.md}"
MATRIX_PATH="${2:-$ROOT_DIR/Documentation/Generated/Device-Coverage-Matrix.md}"
PACKETS_DIR="${3:-$ROOT_DIR/Documentation/Generated/Device-Capture-Packets}"
INDEX_PATH="${4:-$ROOT_DIR/Documentation/Generated/Device-Capture-Packets.md}"
POLICY_PATH="${5:-$ROOT_DIR/Documentation/device-evidence-form-policy.json}"

if [[ "$PLAN_PATH" != /* ]]; then
  PLAN_PATH="$ROOT_DIR/$PLAN_PATH"
fi

if [[ "$MATRIX_PATH" != /* ]]; then
  MATRIX_PATH="$ROOT_DIR/$MATRIX_PATH"
fi

if [[ "$PACKETS_DIR" != /* ]]; then
  PACKETS_DIR="$ROOT_DIR/$PACKETS_DIR"
fi

if [[ "$INDEX_PATH" != /* ]]; then
  INDEX_PATH="$ROOT_DIR/$INDEX_PATH"
fi

if [[ "$POLICY_PATH" != /* ]]; then
  POLICY_PATH="$ROOT_DIR/$POLICY_PATH"
fi

rm -rf "$PACKETS_DIR"
mkdir -p "$PACKETS_DIR"
mkdir -p "$(dirname "$INDEX_PATH")"

ruby - "$PLAN_PATH" "$MATRIX_PATH" "$PACKETS_DIR" "$INDEX_PATH" "$POLICY_PATH" <<'RUBY'
require "fileutils"
require "json"

plan_path, matrix_path, packets_dir, index_path, policy_path = ARGV

abort("Missing device evidence plan: #{plan_path}") unless File.exist?(plan_path)
abort("Missing device coverage matrix: #{matrix_path}") unless File.exist?(matrix_path)
abort("Missing device evidence form policy: #{policy_path}") unless File.exist?(policy_path)

plan = File.read(plan_path)
matrix = File.read(matrix_path)
policy = JSON.parse(File.read(policy_path))

missing_classes = begin
  explicit = matrix[/Missing required release device classes: `([^`]+)`/, 1]
  if explicit
    explicit.split(",").map(&:strip).reject(&:empty?)
  else
    []
  end
end

capture_blocks = plan.scan(/## Wave \d+: ([^\n]+)\n.*?```bash\n(.*?)```/m).map do |title, command|
  device_class = title.sub(/\s+Evidence\z/, "").strip

  {
    device_class: device_class,
    title: title.strip,
    command: command.rstrip,
    profile: command[/--profile ([^\s\\]+)/, 1] || "standard",
    output_dir: command[/--output-dir ([^\s\\]+)/, 1],
    device_name: command[/--device-name "([^"]+)"/, 1],
    device_model: command[/--device-model "([^"]+)"/, 1],
    platform_family: command[/--platform-family ([^\s\\]+)/, 1],
    soc: command[/--soc "([^"]+)"/, 1]
  }
end

entries = capture_blocks.select { |entry| missing_classes.include?(entry[:device_class]) }

entries.each do |entry|
  slug = entry.fetch(:device_class).downcase
  packet_dir = File.join(packets_dir, slug)
  FileUtils.mkdir_p(packet_dir)
  request_type = policy.fetch("defaultRequestType")
  benchmark_profile = policy.fetch("defaultBenchmarkProfile")
  validation_commands = Array(policy.fetch("validationCommands"))
  coverage_artifact_path = policy.fetch("coverageArtifactPath")
  issue_submission_intro = policy.fetch("issueSubmissionIntro")

  capture_script = <<~BASH
    #!/usr/bin/env bash
    set -euo pipefail

    ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
    SNAPSHOT_NAME="${1:?Usage: bash capture.sh <snapshot-name> <export-archive-path> [output-dir]}"
    EXPORT_ARCHIVE="${2:?Usage: bash capture.sh <snapshot-name> <export-archive-path> [output-dir]}"
    OUTPUT_DIR="${3:-$ROOT_DIR/#{entry.fetch(:output_dir)}}"

    bash "$ROOT_DIR/Scripts/run-benchmarks-for-device.sh" \\
      --profile #{entry.fetch(:profile)} \\
      --output-dir "$OUTPUT_DIR" \\
      --snapshot-name "$SNAPSHOT_NAME" \\
      --device-name "#{entry.fetch(:device_name)}" \\
      --device-model "#{entry.fetch(:device_model)}" \\
      --device-class #{entry.fetch(:device_class)} \\
      --platform-family #{entry.fetch(:platform_family)} \\
      --soc "#{entry.fetch(:soc)}" \\
      --export-archive "$EXPORT_ARCHIVE"
  BASH

  import_script = <<~BASH
    #!/usr/bin/env bash
    set -euo pipefail

    ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
    ARCHIVE_PATH="${1:?Usage: bash import.sh <export-archive-path> <snapshot-name>}"
    SNAPSHOT_NAME="${2:?Usage: bash import.sh <export-archive-path> <snapshot-name>}"

    bash "$ROOT_DIR/Scripts/import-benchmark-evidence.sh" \\
      --device-name "#{entry.fetch(:device_name)}" \\
      --device-model "#{entry.fetch(:device_model)}" \\
      --device-class #{entry.fetch(:device_class)} \\
      --platform-family #{entry.fetch(:platform_family)} \\
      --soc "#{entry.fetch(:soc)}" \\
      "$ARCHIVE_PATH" \\
      "$SNAPSHOT_NAME"
  BASH

  metadata_template = {
    "deviceName" => entry.fetch(:device_name),
    "deviceModel" => entry.fetch(:device_model),
    "deviceClass" => entry.fetch(:device_class),
    "platformFamily" => entry.fetch(:platform_family),
    "systemOnChip" => entry.fetch(:soc),
    "notes" => ""
  }

  issue_fields = {
    "request_type" => request_type,
    "device_class" => entry.fetch(:device_class),
    "snapshot_name" => "#{slug}-baseline-<tag-or-date>",
    "device_identity" => "#{entry.fetch(:device_name)} / #{entry.fetch(:device_model)} / #{entry.fetch(:soc)} / #{entry.fetch(:platform_family)}",
    "benchmark_profile" => benchmark_profile,
    "evidence_source" => [
      "Captured with Documentation/Generated/Device-Capture-Packets/#{slug}/capture.sh",
      "Imported with Documentation/Generated/Device-Capture-Packets/#{slug}/import.sh"
    ],
    "artifact_paths" => [
      "/absolute/path/to/#{slug}-benchmark-export.tar.gz",
      "Benchmarks/Results/releases/#{slug}-baseline-<tag-or-date>",
      coverage_artifact_path
    ],
    "validation_commands" => validation_commands,
    "gap_or_problem" => [
      "Confirm the new #{entry.fetch(:device_class)} bundle appears in generated coverage surfaces."
    ],
    "additional_context" => ""
  }

  issue_submission = <<~MARKDOWN
    # #{entry.fetch(:device_class)} Device Evidence Submission

    #{issue_submission_intro}

    ## Suggested Values

    - Request Type: `#{request_type}`
    - Device Class: `#{entry.fetch(:device_class)}`
    - Snapshot Name: `#{slug}-baseline-<tag-or-date>`
    - Device Identity: `#{entry.fetch(:device_name)} / #{entry.fetch(:device_model)} / #{entry.fetch(:soc)} / #{entry.fetch(:platform_family)}`
    - Benchmark Profile: `#{benchmark_profile}`

    ## Evidence Source

    - Captured with `Documentation/Generated/Device-Capture-Packets/#{slug}/capture.sh`
    - Imported with `Documentation/Generated/Device-Capture-Packets/#{slug}/import.sh`

    ## Artifact Paths

    - `/absolute/path/to/#{slug}-benchmark-export.tar.gz`
    - `Benchmarks/Results/releases/#{slug}-baseline-<tag-or-date>`
    - `#{coverage_artifact_path}`

    ## Validation Commands

    ```bash
    #{validation_commands.join("\n")}
    ```

    ## Gap Or Problem

    - Confirm the new `#{entry.fetch(:device_class)}` bundle appears in generated coverage surfaces.
  MARKDOWN

  readme = <<~MARKDOWN
    # #{entry.fetch(:device_class)} Capture Packet

    This packet is generated from the current missing-device benchmark plan.

    ## Normalized Metadata

    - Device class: `#{entry.fetch(:device_class)}`
    - Device name: `#{entry.fetch(:device_name)}`
    - Device model: `#{entry.fetch(:device_model)}`
    - Platform family: `#{entry.fetch(:platform_family)}`
    - System on chip: `#{entry.fetch(:soc)}`

    ## Capture In This Checkout

    ```bash
    bash Documentation/Generated/Device-Capture-Packets/#{slug}/capture.sh \\
      <snapshot-name> \\
      /absolute/path/to/#{slug}-benchmark-export.tar.gz
    ```

    Optional third argument overrides the output directory.

    ## Import On Destination Checkout

    ```bash
    bash Documentation/Generated/Device-Capture-Packets/#{slug}/import.sh \\
      /absolute/path/to/#{slug}-benchmark-export.tar.gz \\
      <snapshot-name>
    ```

    ## Files

    - `capture.sh`: runs a normalized device benchmark and emits a transfer archive
    - `import.sh`: imports that transfer archive into immutable release evidence
    - `device-metadata.json`: metadata template for maintainers or external operators
    - `issue-fields.json`: machine-readable values aligned with the GitHub device evidence issue form
    - `issue-submission.md`: maintainer-facing issue text template
  MARKDOWN

  File.write(File.join(packet_dir, "capture.sh"), capture_script)
  File.write(File.join(packet_dir, "import.sh"), import_script)
  File.write(File.join(packet_dir, "device-metadata.json"), JSON.pretty_generate(metadata_template) + "\n")
  File.write(File.join(packet_dir, "issue-fields.json"), JSON.pretty_generate(issue_fields) + "\n")
  File.write(File.join(packet_dir, "issue-submission.md"), issue_submission)
  File.write(File.join(packet_dir, "README.md"), readme)

  FileUtils.chmod(0o755, File.join(packet_dir, "capture.sh"))
  FileUtils.chmod(0o755, File.join(packet_dir, "import.sh"))
end

File.open(index_path, "w") do |file|
  file.puts "# Device Capture Packets"
  file.puts
  file.puts "Generated handoff packets for the device classes still missing from immutable release evidence."
  file.puts
  file.puts "## Current Gap"
  file.puts
  file.puts "- Missing required release device classes: `#{missing_classes.empty? ? 'none' : missing_classes.join(', ')}`"
  file.puts "- Source plan: [Device-Evidence-Plan.md](Device-Evidence-Plan.md)"
  file.puts "- Source runbook: [Device-Evidence-Runbook.md](Device-Evidence-Runbook.md)"
  file.puts

  if entries.empty?
    file.puts "## Status"
    file.puts
    file.puts "- No missing-device capture packets are required right now."
  else
    file.puts "## Packets"
    file.puts
    entries.each do |entry|
      slug = entry.fetch(:device_class).downcase
      file.puts "### #{entry.fetch(:device_class)}"
      file.puts
      file.puts "- Packet README: [Device-Capture-Packets/#{slug}/README.md](Device-Capture-Packets/#{slug}/README.md)"
      file.puts "- Capture script: [Device-Capture-Packets/#{slug}/capture.sh](Device-Capture-Packets/#{slug}/capture.sh)"
      file.puts "- Import script: [Device-Capture-Packets/#{slug}/import.sh](Device-Capture-Packets/#{slug}/import.sh)"
      file.puts "- Metadata template: [Device-Capture-Packets/#{slug}/device-metadata.json](Device-Capture-Packets/#{slug}/device-metadata.json)"
      file.puts "- Issue fields: [Device-Capture-Packets/#{slug}/issue-fields.json](Device-Capture-Packets/#{slug}/issue-fields.json)"
      file.puts "- Issue submission: [Device-Capture-Packets/#{slug}/issue-submission.md](Device-Capture-Packets/#{slug}/issue-submission.md)"
      file.puts
    end
  end
end

puts "Device capture packets generated at #{packets_dir}"
puts "Index generated at #{index_path}"
RUBY
