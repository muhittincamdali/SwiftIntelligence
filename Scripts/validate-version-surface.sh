#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RELEASE_TAG="${1:-}"

ruby - "$ROOT_DIR" "$RELEASE_TAG" <<'RUBY'
root_dir, release_tag = ARGV

changelog_path = File.join(root_dir, "CHANGELOG.md")
readme_path = File.join(root_dir, "README.md")
readme_tr_path = File.join(root_dir, "README_TR.md")

[changelog_path, readme_path, readme_tr_path].each do |path|
  abort("Missing required file: #{path}") unless File.exist?(path)
end

changelog = File.read(changelog_path)
readme = File.read(readme_path)
readme_tr = File.read(readme_tr_path)

release_sections = changelog.scan(/^## (\d+\.\d+\.\d+) - .+$/).flatten
abort("CHANGELOG must contain at least one numbered release section.") if release_sections.empty?

latest_release = release_sections.first

readme_version = readme[/\.package\(url: "https:\/\/github\.com\/muhittincamdali\/SwiftIntelligence\.git", from: "([^"]+)"\)/, 1]
abort("README.md is missing the Swift Package Manager installation snippet.") if readme_version.nil?

readme_tr_version = readme_tr[/\.package\(url: "https:\/\/github\.com\/muhittincamdali\/SwiftIntelligence\.git", from: "([^"]+)"\)/, 1]
abort("README_TR.md is missing the Swift Package Manager installation snippet.") if readme_tr_version.nil?

abort("README.md install version #{readme_version} does not match latest changelog release #{latest_release}.") unless readme_version == latest_release
abort("README_TR.md install version #{readme_tr_version} does not match latest changelog release #{latest_release}.") unless readme_tr_version == latest_release

unless release_tag.nil? || release_tag.empty?
  normalized_tag = release_tag.sub(/\Av/, "")
  abort("Release tag #{release_tag} does not match latest changelog release #{latest_release}.") unless normalized_tag == latest_release
end

puts "Version surface validation passed for #{latest_release}."
RUBY
