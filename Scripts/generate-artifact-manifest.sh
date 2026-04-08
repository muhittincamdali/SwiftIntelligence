#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="${1:-$ROOT_DIR/Benchmarks/Results/latest}"
MANIFEST_PATH="${2:-}"
CHECKSUMS_PATH="${3:-}"

if [[ "$TARGET_DIR" != /* ]]; then
  TARGET_DIR="$ROOT_DIR/$TARGET_DIR"
fi

if [[ ! -d "$TARGET_DIR" ]]; then
  echo "Artifact directory does not exist: $TARGET_DIR" >&2
  exit 1
fi

if [[ -z "$MANIFEST_PATH" ]]; then
  MANIFEST_PATH="$TARGET_DIR/artifact-manifest.json"
elif [[ "$MANIFEST_PATH" != /* ]]; then
  MANIFEST_PATH="$ROOT_DIR/$MANIFEST_PATH"
fi

if [[ -z "$CHECKSUMS_PATH" ]]; then
  CHECKSUMS_PATH="$TARGET_DIR/checksums.txt"
elif [[ "$CHECKSUMS_PATH" != /* ]]; then
  CHECKSUMS_PATH="$ROOT_DIR/$CHECKSUMS_PATH"
fi

mkdir -p "$(dirname "$MANIFEST_PATH")"
mkdir -p "$(dirname "$CHECKSUMS_PATH")"

ruby - "$ROOT_DIR" "$TARGET_DIR" "$MANIFEST_PATH" "$CHECKSUMS_PATH" <<'RUBY'
require "json"
require "digest"
require "pathname"
require "time"

root_dir, target_dir, manifest_path, checksums_path = ARGV

def safe_relative(root_dir, path)
  Pathname.new(path).relative_path_from(Pathname.new(root_dir)).to_s
rescue StandardError
  path
end

entries = Dir.children(target_dir)
  .sort
  .reject { |name| [".DS_Store", File.basename(manifest_path), File.basename(checksums_path)].include?(name) }
  .map do |name|
    path = File.join(target_dir, name)
    next unless File.file?(path)

    {
      "name" => name,
      "relativePath" => safe_relative(root_dir, path),
      "size" => File.size(path),
      "sha256" => Digest::SHA256.file(path).hexdigest
    }
  end
  .compact

abort("No files available to describe in artifact manifest for #{target_dir}") if entries.empty?

manifest = {
  generatedAt: Time.now.utc.iso8601,
  artifactDirectory: safe_relative(root_dir, target_dir),
  fileCount: entries.length,
  files: entries
}

File.write(manifest_path, JSON.pretty_generate(manifest) + "\n")

File.open(checksums_path, "w") do |file|
  entries.each do |entry|
    file.puts "#{entry.fetch("sha256")}  #{entry.fetch("name")}"
  end
end

puts "Artifact manifest generated at #{manifest_path}"
puts "Artifact checksums generated at #{checksums_path}"
RUBY
