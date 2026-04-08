#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
POLICY_PATH="${1:-$ROOT_DIR/Documentation/flagship-media-policy.json}"
MEDIA_README_PATH="${2:-$ROOT_DIR/Documentation/Assets/Flagship-Demo/README.md}"

if [[ "$POLICY_PATH" != /* ]]; then
  POLICY_PATH="$ROOT_DIR/$POLICY_PATH"
fi

if [[ "$MEDIA_README_PATH" != /* ]]; then
  MEDIA_README_PATH="$ROOT_DIR/$MEDIA_README_PATH"
fi

ruby - "$ROOT_DIR" "$POLICY_PATH" "$MEDIA_README_PATH" <<'RUBY'
require "json"
require "pathname"

root_dir, policy_path, media_readme_path = ARGV

abort("Missing flagship media policy: #{policy_path}") unless File.exist?(policy_path)
abort("Missing flagship media README: #{media_readme_path}") unless File.exist?(media_readme_path)

policy = JSON.parse(File.read(policy_path))
asset_root = File.expand_path(policy.fetch("assetRoot"), root_dir)
abort("Missing flagship media asset root: #{asset_root}") unless Dir.exist?(asset_root)

status_values = Array(policy.fetch("statusValues"))
required_files = Array(policy.fetch("requiredFilesWhenPublished"))

readme = File.read(media_readme_path)
status = readme[/Current status: `([^`]+)`/, 1]
abort("Flagship media README must declare current status.") unless status
abort("Invalid flagship media status: #{status}") unless status_values.include?(status)

existing_files = Dir.children(asset_root)
  .reject { |name| name == "README.md" || name.start_with?(".") }
  .select { |name| File.file?(File.join(asset_root, name)) }
  .sort

errors = []

if status == "published"
  required_files.each do |name|
    errors << "Missing required published media asset #{name} in #{asset_root}" unless existing_files.include?(name)
  end
else
  if existing_files.any?
    errors << "Flagship media status is not-published but media files already exist: #{existing_files.join(', ')}"
  end
end

if errors.empty?
  puts "Flagship media assets validated with status '#{status}'."
  exit 0
end

warn "Flagship media asset validation failed:"
errors.each { |error| warn "- #{error}" }
exit 1
RUBY
