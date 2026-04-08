#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHANGELOG_PATH="${1:-$ROOT_DIR/CHANGELOG.md}"
RELEASE_TAG="${2:-}"

if [[ "$CHANGELOG_PATH" != /* ]]; then
  CHANGELOG_PATH="$ROOT_DIR/$CHANGELOG_PATH"
fi

if [[ ! -f "$CHANGELOG_PATH" ]]; then
  echo "Missing changelog file: $CHANGELOG_PATH" >&2
  exit 1
fi

ruby - "$CHANGELOG_PATH" "$RELEASE_TAG" <<'RUBY'
changelog_path, release_tag = ARGV
content = File.read(changelog_path)

abort("CHANGELOG is empty.") if content.strip.empty?
abort("CHANGELOG must start with '# Changelog'.") unless content.start_with?("# Changelog")

banned_terms = [
  "100% complete",
  "production-ready",
  "world-class",
  "SwiftUILab",
  "IntelligenceEngine",
  "SwiftIntelligenceImageGeneration"
]

matched_term = banned_terms.find { |term| content.include?(term) }
abort("CHANGELOG contains banned stale claim/reference: #{matched_term}") if matched_term

sections = content.split(/^## /).drop(1).map do |raw_section|
  heading, *body_lines = raw_section.lines
  {
    heading: heading.to_s.strip,
    body: body_lines.join
  }
end

unreleased = sections.find { |section| section[:heading] == "Unreleased" }
abort("CHANGELOG must contain an '## Unreleased' section.") if unreleased.nil?

unreleased_bullets = unreleased[:body].lines.map(&:strip).select { |line| line.start_with?("- ") }
abort("CHANGELOG Unreleased section must contain at least one bullet.") if unreleased_bullets.empty?

if !release_tag.nil? && !release_tag.empty?
  release_version = release_tag.sub(/\Av/, "")
  release_heading_prefix = "#{release_version} - "
  matched_release = sections.find { |section| section[:heading].start_with?(release_heading_prefix) }
  abort("CHANGELOG is missing a release section for #{release_tag}.") if matched_release.nil?

  release_bullets = matched_release[:body].lines.map(&:strip).select { |line| line.start_with?("- ") }
  abort("CHANGELOG section for #{release_tag} must contain at least one bullet.") if release_bullets.empty?
end

puts "CHANGELOG validation passed."
RUBY
