#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_PATH="${1:-}"

if [[ -z "$OUTPUT_PATH" ]]; then
  echo "Usage: bash Scripts/export-flagship-demo-share-pack.sh <output-tar.gz>" >&2
  exit 1
fi

if [[ "$OUTPUT_PATH" != /* ]]; then
  OUTPUT_PATH="$ROOT_DIR/$OUTPUT_PATH"
fi

FLAGSHIP_PACK_PATH="$ROOT_DIR/Documentation/Generated/Flagship-Demo-Pack.md"
FLAGSHIP_MEDIA_STATUS_PATH="$ROOT_DIR/Documentation/Generated/Flagship-Media-Status.md"
PUBLIC_PROOF_STATUS_PATH="$ROOT_DIR/Documentation/Generated/Public-Proof-Status.md"
LATEST_RELEASE_PROOF_PATH="$ROOT_DIR/Documentation/Generated/Latest-Release-Proof.md"
SHOWCASE_PATH="$ROOT_DIR/Documentation/Showcase.md"
DEMO_GUIDE_PATH="$ROOT_DIR/Examples/DemoApps/IntelligentCamera/README.md"
DEMO_SOURCE_PATH="$ROOT_DIR/Examples/DemoApps/IntelligentCamera/IntelligentCameraApp.swift"
MEDIA_ROOT="$ROOT_DIR/Documentation/Assets/Flagship-Demo"
MEDIA_README_PATH="$MEDIA_ROOT/README.md"
MEDIA_SCREENSHOT_PATH="$MEDIA_ROOT/intelligent-camera-success.png"
MEDIA_VIDEO_PATH="$MEDIA_ROOT/intelligent-camera-run.mp4"
MEDIA_CAPTION_PATH="$MEDIA_ROOT/caption.txt"

required_paths=(
  "$FLAGSHIP_PACK_PATH"
  "$FLAGSHIP_MEDIA_STATUS_PATH"
  "$PUBLIC_PROOF_STATUS_PATH"
  "$LATEST_RELEASE_PROOF_PATH"
  "$SHOWCASE_PATH"
  "$DEMO_GUIDE_PATH"
  "$DEMO_SOURCE_PATH"
)

for path in "${required_paths[@]}"; do
  if [[ ! -f "$path" ]]; then
    echo "Missing required share-pack source: $path" >&2
    exit 1
  fi
done

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

pack_root="$tmp_dir/swiftintelligence-flagship-demo-pack"
mkdir -p "$pack_root/Documentation/Generated" "$pack_root/Examples/DemoApps/IntelligentCamera"

cp "$FLAGSHIP_PACK_PATH" "$pack_root/Documentation/Generated/Flagship-Demo-Pack.md"
cp "$FLAGSHIP_MEDIA_STATUS_PATH" "$pack_root/Documentation/Generated/Flagship-Media-Status.md"
cp "$PUBLIC_PROOF_STATUS_PATH" "$pack_root/Documentation/Generated/Public-Proof-Status.md"
cp "$LATEST_RELEASE_PROOF_PATH" "$pack_root/Documentation/Generated/Latest-Release-Proof.md"
cp "$SHOWCASE_PATH" "$pack_root/Documentation/Showcase.md"
cp "$DEMO_GUIDE_PATH" "$pack_root/Examples/DemoApps/IntelligentCamera/README.md"
cp "$DEMO_SOURCE_PATH" "$pack_root/Examples/DemoApps/IntelligentCamera/IntelligentCameraApp.swift"

if [[ -f "$MEDIA_README_PATH" ]]; then
  mkdir -p "$pack_root/Documentation/Assets/Flagship-Demo"
  cp "$MEDIA_README_PATH" "$pack_root/Documentation/Assets/Flagship-Demo/README.md"
fi

if [[ -f "$MEDIA_SCREENSHOT_PATH" && -f "$MEDIA_VIDEO_PATH" && -f "$MEDIA_CAPTION_PATH" ]]; then
  mkdir -p "$pack_root/Documentation/Assets/Flagship-Demo"
  cp "$MEDIA_SCREENSHOT_PATH" "$pack_root/Documentation/Assets/Flagship-Demo/intelligent-camera-success.png"
  cp "$MEDIA_VIDEO_PATH" "$pack_root/Documentation/Assets/Flagship-Demo/intelligent-camera-run.mp4"
  cp "$MEDIA_CAPTION_PATH" "$pack_root/Documentation/Assets/Flagship-Demo/caption.txt"
fi

cat > "$pack_root/README.md" <<'EOF'
# SwiftIntelligence Flagship Demo Share Pack

Use this pack when preparing a release post, evaluator handoff, or short showcase asset wave for the strongest current demo path.

## Included Files

- `Documentation/Generated/Flagship-Demo-Pack.md`
- `Documentation/Generated/Flagship-Media-Status.md`
- `Documentation/Generated/Public-Proof-Status.md`
- `Documentation/Generated/Latest-Release-Proof.md`
- `Documentation/Showcase.md`
- `Examples/DemoApps/IntelligentCamera/README.md`
- `Examples/DemoApps/IntelligentCamera/IntelligentCameraApp.swift`
- `Documentation/Assets/Flagship-Demo/*` when repo-native media is published

## Fastest Use

1. Read `Documentation/Generated/Flagship-Demo-Pack.md`.
2. Open `Examples/DemoApps/IntelligentCamera/README.md`.
3. Run the demo path on `macOS 14+` or `iOS 17+`.
4. If repo-native media assets are included, reuse them only with the same proof posture and caption.
5. Otherwise capture one screenshot and one short recording only after the visible success signals are present.

## Recommended Asset Names

- `intelligent-camera-success.png`
- `intelligent-camera-run.mp4`
- `caption.txt`

## Caption Baseline

`Vision -> NLP -> Privacy in one Apple-native Swift package workflow`

## Truthfulness Rules

- do not present simulator output as mobile release evidence
- do not crop out missing or empty success signals
- do not claim category leadership from demo media alone
EOF

bash "$ROOT_DIR/Scripts/generate-artifact-manifest.sh" "$pack_root" "$pack_root/artifact-manifest.json" "$pack_root/checksums.txt" >/dev/null

mkdir -p "$(dirname "$OUTPUT_PATH")"
tar -czf "$OUTPUT_PATH" -C "$tmp_dir" "swiftintelligence-flagship-demo-pack"

echo "Flagship demo share pack exported to $OUTPUT_PATH"
