#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
POLICY_PATH="${1:-$ROOT_DIR/Documentation/public-claims-policy.json}"

if [[ "$POLICY_PATH" != /* ]]; then
  POLICY_PATH="$ROOT_DIR/$POLICY_PATH"
fi

ruby - "$ROOT_DIR" "$POLICY_PATH" <<'RUBY'
require "json"

root_dir, policy_path = ARGV

abort("Missing public claims policy: #{policy_path}") unless File.exist?(policy_path)

policy = JSON.parse(File.read(policy_path))
readiness_file = File.join(root_dir, policy.fetch("readinessFile"))
abort("Missing readiness file: #{readiness_file}") unless File.exist?(readiness_file)

readiness = File.read(readiness_file)
publish_readiness = readiness[/Publish readiness: `([^`]+)`/, 1] || "unknown"

if publish_readiness == "ready"
  puts "Public claims validation skipped: publish readiness is ready."
  exit 0
end

forbidden_patterns = Array(policy.fetch("forbiddenPatternsWhenNotReady")).map { |pattern| Regexp.new(pattern, Regexp::IGNORECASE) }
allowed_context_patterns = Array(policy.fetch("allowedContextPatterns")).map { |pattern| Regexp.new(pattern, Regexp::IGNORECASE) }
files = Array(policy.fetch("files"))

violations = []

files.each do |relative_path|
  absolute_path = File.join(root_dir, relative_path)
  next unless File.exist?(absolute_path)

  File.readlines(absolute_path, chomp: true).each_with_index do |line, index|
    next if allowed_context_patterns.any? { |pattern| line.match?(pattern) }

    forbidden_patterns.each do |pattern|
      next unless line.match?(pattern)

      violations << {
        file: relative_path,
        line: index + 1,
        content: line.strip,
        pattern: pattern.source
      }
    end
  end
end

if violations.empty?
  puts "Public claims validation passed for readiness '#{publish_readiness}'."
  exit 0
end

warn "Public claims validation failed while publish readiness is '#{publish_readiness}'."
warn "Remove or soften benchmark/performance leadership claims until multi-device readiness is complete."

violations.each do |violation|
  warn "- #{violation[:file]}:#{violation[:line]} matched /#{violation[:pattern]}/"
  warn "  #{violation[:content]}"
end

exit 1
RUBY
