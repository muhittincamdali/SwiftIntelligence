#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKFLOW_PATH="${1:-$ROOT_DIR/.github/workflows/release.yml}"
POLICY_PATH="${2:-$ROOT_DIR/Documentation/release-asset-policy.json}"

if [[ "$WORKFLOW_PATH" != /* ]]; then
  WORKFLOW_PATH="$ROOT_DIR/$WORKFLOW_PATH"
fi

if [[ "$POLICY_PATH" != /* ]]; then
  POLICY_PATH="$ROOT_DIR/$POLICY_PATH"
fi

ruby - "$WORKFLOW_PATH" "$POLICY_PATH" <<'RUBY'
require "json"
require "yaml"

workflow_path, policy_path = ARGV

abort("Missing release workflow: #{workflow_path}") unless File.exist?(workflow_path)
abort("Missing release asset policy: #{policy_path}") unless File.exist?(policy_path)

workflow = YAML.load_file(workflow_path)
policy = JSON.parse(File.read(policy_path))
required_assets = Array(policy["requiredReleaseAssets"])

jobs = workflow["jobs"] || {}
release_job = jobs["release"] || {}
steps = Array(release_job["steps"])
create_release_step = steps.find do |step|
  step["uses"].to_s.include?("softprops/action-gh-release")
end

abort("Create Release step not found in #{workflow_path}") unless create_release_step

files_block = create_release_step.dig("with", "files").to_s
declared_assets = files_block
  .lines
  .map(&:strip)
  .reject(&:empty?)
  .map do |line|
    line.sub("${{ steps.evidence.outputs.dir }}/", "")
  end

missing_assets = required_assets.reject { |asset| declared_assets.include?(asset) }

if missing_assets.empty?
  puts "Release workflow asset list validated for #{required_assets.length} required asset(s)."
  exit 0
end

warn "Release workflow asset validation failed:"
missing_assets.each do |asset|
  warn "- Missing asset in workflow files list: #{asset}"
end
exit 1
RUBY
