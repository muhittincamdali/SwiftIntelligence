#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RESULTS_ROOT="${1:-$ROOT_DIR/Benchmarks/Results}"
POLICY_PATH="${2:-$ROOT_DIR/Documentation/release-asset-policy.json}"

if [[ "$RESULTS_ROOT" != /* ]]; then
  RESULTS_ROOT="$ROOT_DIR/$RESULTS_ROOT"
fi

if [[ "$POLICY_PATH" != /* ]]; then
  POLICY_PATH="$ROOT_DIR/$POLICY_PATH"
fi

ruby - "$RESULTS_ROOT" "$POLICY_PATH" <<'RUBY'
require "json"
require "open3"

results_root, policy_path = ARGV
releases_root = File.join(results_root, "releases")

abort("Missing release asset policy: #{policy_path}") unless File.exist?(policy_path)
policy = JSON.parse(File.read(policy_path))
required_assets = Array(policy["requiredReleaseAssets"])

unless Dir.exist?(releases_root)
  puts "Release evidence asset validation skipped: no releases directory."
  exit 0
end

errors = []
validated = 0

Dir.children(releases_root).sort.each do |child|
  bundle_dir = File.join(releases_root, child)
  next unless File.directory?(bundle_dir)

  metadata_path = File.join(bundle_dir, "metadata.json")
  next unless File.exist?(metadata_path)

  public_proof_json_path = File.join(bundle_dir, "public-proof-status.json")
  public_proof_md_path = File.join(bundle_dir, "public-proof-status.md")
  blockers_path = File.join(bundle_dir, "release-blockers.md")
  handoff_md_path = File.join(bundle_dir, "device-evidence-handoff.md")
  handoff_json_path = File.join(bundle_dir, "device-evidence-handoff.json")
  handoff_archive_path = File.join(bundle_dir, "device-evidence-handoff.tar.gz")
  share_pack_path = File.join(bundle_dir, "flagship-demo-share-pack.tar.gz")

  missing_classes = []
  flagship_media_status = "unknown"
  if File.exist?(public_proof_json_path)
    public_proof = JSON.parse(File.read(public_proof_json_path))
    missing_classes = Array(public_proof["missingRequiredDeviceClasses"])
    flagship_media_status = public_proof["flagshipMediaStatus"].to_s
  end

  conditional_assets = {
    "device-evidence-handoff.tar.gz" => missing_classes.any?
  }

  required_assets.each do |asset|
    required = conditional_assets.fetch(asset, true)
    next unless required

    asset_path = File.join(bundle_dir, asset)
    errors << "Missing #{asset} in #{bundle_dir}" unless File.exist?(asset_path)
  end

  if flagship_media_status == "published" && File.exist?(share_pack_path)
    tar_list, status = Open3.capture2("tar", "-tzf", share_pack_path)
    unless status.success?
      errors << "Could not inspect flagship-demo-share-pack.tar.gz in #{bundle_dir}"
      next
    end

    required_share_pack_entries = [
      "swiftintelligence-flagship-demo-pack/Documentation/Assets/Flagship-Demo/README.md",
      "swiftintelligence-flagship-demo-pack/Documentation/Assets/Flagship-Demo/intelligent-camera-success.png",
      "swiftintelligence-flagship-demo-pack/Documentation/Assets/Flagship-Demo/intelligent-camera-run.mp4",
      "swiftintelligence-flagship-demo-pack/Documentation/Assets/Flagship-Demo/caption.txt"
    ]

    required_share_pack_entries.each do |entry|
      errors << "Missing #{entry} inside #{share_pack_path}" unless tar_list.include?(entry)
    end
  end

  validated += 1
end

if errors.empty?
  puts "Release evidence assets validated for #{validated} bundle(s)."
  exit 0
end

warn "Release evidence asset validation failed:"
errors.each { |error| warn "- #{error}" }
exit 1
RUBY
