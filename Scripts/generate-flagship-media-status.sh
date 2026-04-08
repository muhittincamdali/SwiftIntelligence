#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
POLICY_PATH="${1:-$ROOT_DIR/Documentation/flagship-media-policy.json}"
MEDIA_README_PATH="${2:-$ROOT_DIR/Documentation/Assets/Flagship-Demo/README.md}"
MARKDOWN_OUTPUT="${3:-$ROOT_DIR/Documentation/Generated/Flagship-Media-Status.md}"
JSON_OUTPUT="${4:-$ROOT_DIR/Documentation/Generated/flagship-media-status.json}"

if [[ "$POLICY_PATH" != /* ]]; then
  POLICY_PATH="$ROOT_DIR/$POLICY_PATH"
fi

if [[ "$MEDIA_README_PATH" != /* ]]; then
  MEDIA_README_PATH="$ROOT_DIR/$MEDIA_README_PATH"
fi

if [[ "$MARKDOWN_OUTPUT" != /* ]]; then
  MARKDOWN_OUTPUT="$ROOT_DIR/$MARKDOWN_OUTPUT"
fi

if [[ "$JSON_OUTPUT" != /* ]]; then
  JSON_OUTPUT="$ROOT_DIR/$JSON_OUTPUT"
fi

mkdir -p "$(dirname "$MARKDOWN_OUTPUT")"
mkdir -p "$(dirname "$JSON_OUTPUT")"

ruby - "$ROOT_DIR" "$POLICY_PATH" "$MEDIA_README_PATH" "$MARKDOWN_OUTPUT" "$JSON_OUTPUT" <<'RUBY'
require "json"
require "pathname"

root_dir, policy_path, media_readme_path, markdown_output, json_output = ARGV

abort("Missing flagship media policy: #{policy_path}") unless File.exist?(policy_path)
abort("Missing flagship media README: #{media_readme_path}") unless File.exist?(media_readme_path)

policy = JSON.parse(File.read(policy_path))
media_readme = File.read(media_readme_path)

asset_root = File.expand_path(policy.fetch("assetRoot"), root_dir)
status = media_readme[/Current status: `([^`]+)`/, 1] || "unknown"
required_files = Array(policy.fetch("requiredFilesWhenPublished"))

present_files = if Dir.exist?(asset_root)
  Dir.children(asset_root)
    .reject { |name| name == "README.md" || name.start_with?(".") }
    .select { |name| File.file?(File.join(asset_root, name)) }
    .sort
else
  []
end

missing_files = status == "published" ? (required_files - present_files) : required_files

json_payload = {
  "status" => status,
  "assetRoot" => Pathname.new(asset_root).relative_path_from(Pathname.new(root_dir)).to_s,
  "requiredFilesWhenPublished" => required_files,
  "presentFiles" => present_files,
  "missingFiles" => missing_files
}

File.write(json_output, JSON.pretty_generate(json_payload) + "\n")

File.open(markdown_output, "w") do |file|
  file.puts "# Flagship Media Status"
  file.puts
  file.puts "Generated status for repo-native showcase media for the `Intelligent Camera` flagship path."
  file.puts
  file.puts "## Status"
  file.puts
  file.puts "- Current status: `#{status}`"
  file.puts "- Canonical asset root: [`#{json_payload["assetRoot"]}`](../Assets/Flagship-Demo/README.md)"
  file.puts "- Machine-readable payload: [flagship-media-status.json](flagship-media-status.json)"
  file.puts
  file.puts "## Required Files When Published"
  file.puts
  required_files.each do |name|
    file.puts "- `#{name}`"
  end
  file.puts
  file.puts "## Current Files"
  file.puts
  if present_files.empty?
    file.puts "- none"
  else
    present_files.each do |name|
      file.puts "- `#{name}`"
    end
  end
  file.puts
  file.puts "## Distribution Guidance"
  file.puts
  if status == "published"
    file.puts "- repo-native flagship media is published and can be linked from README or showcase surfaces"
  else
    file.puts "- repo-native flagship media is not published yet"
    file.puts "- use [Flagship-Demo-Pack.md](Flagship-Demo-Pack.md) and the immutable share pack until real screenshot/video assets are checked in"
  end
end

puts "Flagship media status generated at #{markdown_output}"
puts "Flagship media status JSON generated at #{json_output}"
RUBY
