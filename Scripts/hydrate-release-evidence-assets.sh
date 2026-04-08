#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="${1:-}"

if [[ -z "$TARGET_DIR" ]]; then
  echo "Usage: bash Scripts/hydrate-release-evidence-assets.sh <release-bundle-dir>" >&2
  exit 1
fi

if [[ "$TARGET_DIR" != /* ]]; then
  TARGET_DIR="$ROOT_DIR/$TARGET_DIR"
fi

if [[ ! -d "$TARGET_DIR" ]]; then
  echo "Release bundle directory does not exist: $TARGET_DIR" >&2
  exit 1
fi

generated_release_blockers="$ROOT_DIR/Documentation/Generated/Release-Blockers.md"
generated_public_proof_md="$ROOT_DIR/Documentation/Generated/Public-Proof-Status.md"
generated_public_proof_json="$ROOT_DIR/Documentation/Generated/public-proof-status.json"
generated_flagship_demo_pack="$ROOT_DIR/Documentation/Generated/Flagship-Demo-Pack.md"
generated_handoff_md="$ROOT_DIR/Documentation/Generated/Device-Evidence-Handoff.md"
generated_handoff_json="$ROOT_DIR/Documentation/Generated/device-evidence-handoff.json"
published_flagship_media_root="$ROOT_DIR/Documentation/Assets/Flagship-Demo"
metadata_path="$TARGET_DIR/metadata.json"

if [[ -f "$generated_release_blockers" ]]; then
  cp "$generated_release_blockers" "$TARGET_DIR/release-blockers.md"
fi

if [[ -f "$generated_public_proof_md" ]]; then
  cp "$generated_public_proof_md" "$TARGET_DIR/public-proof-status.md"
fi

if [[ -f "$generated_public_proof_json" ]]; then
  cp "$generated_public_proof_json" "$TARGET_DIR/public-proof-status.json"
fi

if [[ -f "$generated_flagship_demo_pack" ]]; then
  cp "$generated_flagship_demo_pack" "$TARGET_DIR/flagship-demo-pack.md"
fi

if [[ -f "$generated_handoff_md" ]]; then
  cp "$generated_handoff_md" "$TARGET_DIR/device-evidence-handoff.md"
fi

if [[ -f "$generated_handoff_json" ]]; then
  cp "$generated_handoff_json" "$TARGET_DIR/device-evidence-handoff.json"
  handoff_queue_size="$(ruby -rjson -e 'payload = JSON.parse(File.read(ARGV[0])); puts payload.fetch("queueSize")' "$generated_handoff_json")"
  if [[ "$handoff_queue_size" != "0" ]]; then
    bash "$ROOT_DIR/Scripts/export-device-evidence-handoff.sh" "$TARGET_DIR/device-evidence-handoff.tar.gz" >/dev/null
  else
    rm -f "$TARGET_DIR/device-evidence-handoff.tar.gz"
  fi
fi

bash "$ROOT_DIR/Scripts/generate-release-notes-proof.sh" "$TARGET_DIR" "$TARGET_DIR/release-notes-proof.md" >/dev/null
bash "$ROOT_DIR/Scripts/export-flagship-demo-share-pack.sh" "$TARGET_DIR/flagship-demo-share-pack.tar.gz" >/dev/null

for media_asset in intelligent-camera-success.png intelligent-camera-run.mp4 caption.txt; do
  media_source_path="$published_flagship_media_root/$media_asset"
  if [[ -f "$media_source_path" ]]; then
    cp "$media_source_path" "$TARGET_DIR/$media_asset"
  fi
done

if [[ -f "$metadata_path" ]]; then
  release_ref="$(ruby -rjson -e 'payload = JSON.parse(File.read(ARGV[0])); puts(payload["gitRef"] || payload["snapshotName"] || File.basename(File.dirname(ARGV[0])))' "$metadata_path")"
else
  release_ref="$(basename "$TARGET_DIR")"
fi

bash "$ROOT_DIR/Scripts/build-release-notes.sh" "$release_ref" "$TARGET_DIR" "$TARGET_DIR/release-body.md" "SwiftIntelligence" >/dev/null

bash "$ROOT_DIR/Scripts/generate-artifact-manifest.sh" "$TARGET_DIR" "$TARGET_DIR/artifact-manifest.json" "$TARGET_DIR/checksums.txt" >/dev/null

echo "Hydrated release evidence assets in $TARGET_DIR"
