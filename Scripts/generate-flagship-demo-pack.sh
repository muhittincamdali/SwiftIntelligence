#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PUBLIC_PROOF_STATUS_PATH="${1:-$ROOT_DIR/Documentation/Generated/Public-Proof-Status.md}"
LATEST_RELEASE_PROOF_PATH="${2:-$ROOT_DIR/Documentation/Generated/Latest-Release-Proof.md}"
OUTPUT_PATH="${3:-$ROOT_DIR/Documentation/Generated/Flagship-Demo-Pack.md}"
FLAGSHIP_MEDIA_STATUS_PATH="${4:-$ROOT_DIR/Documentation/Generated/Flagship-Media-Status.md}"

if [[ "$PUBLIC_PROOF_STATUS_PATH" != /* ]]; then
  PUBLIC_PROOF_STATUS_PATH="$ROOT_DIR/$PUBLIC_PROOF_STATUS_PATH"
fi

if [[ "$LATEST_RELEASE_PROOF_PATH" != /* ]]; then
  LATEST_RELEASE_PROOF_PATH="$ROOT_DIR/$LATEST_RELEASE_PROOF_PATH"
fi

if [[ "$OUTPUT_PATH" != /* ]]; then
  OUTPUT_PATH="$ROOT_DIR/$OUTPUT_PATH"
fi

if [[ "$FLAGSHIP_MEDIA_STATUS_PATH" != /* ]]; then
  FLAGSHIP_MEDIA_STATUS_PATH="$ROOT_DIR/$FLAGSHIP_MEDIA_STATUS_PATH"
fi

mkdir -p "$(dirname "$OUTPUT_PATH")"

ruby - "$PUBLIC_PROOF_STATUS_PATH" "$LATEST_RELEASE_PROOF_PATH" "$OUTPUT_PATH" "$FLAGSHIP_MEDIA_STATUS_PATH" <<'RUBY'
public_proof_status_path, latest_release_proof_path, output_path, flagship_media_status_path = ARGV

public_proof_status = File.exist?(public_proof_status_path) ? File.read(public_proof_status_path) : ""
latest_release_proof = File.exist?(latest_release_proof_path) ? File.read(latest_release_proof_path) : ""
flagship_media_status = File.exist?(flagship_media_status_path) ? File.read(flagship_media_status_path) : ""

publish_readiness = public_proof_status[/Publish readiness: `([^`]+)`/, 1] || "unknown"
distribution_posture = public_proof_status[/Distribution posture: `([^`]+)`/, 1] || "unknown"
device_classes = public_proof_status[/Device classes seen: `([^`]+)`/, 1] || "unknown"
missing_required = public_proof_status[/Missing required device classes: `([^`]+)`/, 1] || "unknown"
release_bundle = latest_release_proof[/Release: `([^`]+)`/, 1] ||
  latest_release_proof[/Release bundle: `([^`]+)`/, 1] ||
  latest_release_proof[/Evidence bundle: `([^`]+)`/, 1] ||
  "unknown"
media_status = flagship_media_status[/Current status: `([^`]+)`/, 1] || "unknown"
published_media = media_status == "published"

File.open(output_path, "w") do |file|
  file.puts "# Flagship Demo Pack"
  file.puts
  file.puts "Shareable maintainer pack for the strongest current SwiftIntelligence demo path."
  file.puts
  file.puts "## Current Proof Posture"
  file.puts
  file.puts "- publish readiness: `#{publish_readiness}`"
  file.puts "- distribution posture: `#{distribution_posture}`"
  file.puts "- device classes covered: `#{device_classes}`"
  file.puts "- missing required device classes: `#{missing_required}`"
  file.puts "- latest immutable release proof: `#{release_bundle}`"
  file.puts "- repo-native flagship media: `#{media_status}`"
  file.puts
  file.puts "## What To Show First"
  file.puts
  file.puts "- demo: [Intelligent Camera](../../Examples/DemoApps/IntelligentCamera/README.md)"
  file.puts "- flow: `Vision -> NLP -> Privacy`"
  file.puts "- proof command: `bash Scripts/validate-flagship-demo.sh`"
  file.puts "- trust surface: [Public Proof Status](Public-Proof-Status.md)"
  file.puts "- media status: [Flagship-Media-Status.md](Flagship-Media-Status.md)"
  if published_media
    file.puts "- screenshot: [intelligent-camera-success.png](../Assets/Flagship-Demo/intelligent-camera-success.png)"
    file.puts "- recording: [intelligent-camera-run.mp4](../Assets/Flagship-Demo/intelligent-camera-run.mp4)"
    file.puts "- caption: [caption.txt](../Assets/Flagship-Demo/caption.txt)"
  end
  file.puts
  file.puts "## 30-Second Story"
  file.puts
  file.puts "SwiftIntelligence is strongest when it connects multiple Apple-native AI frameworks inside one Swift package workflow. Intelligent Camera is the shortest honest proof of that story: Vision extracts signals from a frame, NLP summarizes recognized text, and Privacy tokenizes sensitive output before it is shown."
  file.puts
  file.puts "## Fastest Demo Run Path"
  file.puts
  file.puts "1. Add `Core + Vision + NLP + Privacy` to a SwiftUI app target."
  file.puts "2. Replace the default app entry with [IntelligentCameraApp.swift](../../Examples/DemoApps/IntelligentCamera/IntelligentCameraApp.swift)."
  file.puts "3. Run on `macOS 14+` or `iOS 17+`."
  file.puts "4. Tap `Analyze Frame`."
  file.puts
  file.puts "## Success Signals"
  file.puts
  file.puts "- `Status` ends with `Vision -> NLP -> Privacy zinciri tamamlandi`"
  file.puts "- `Top labels` is populated"
  file.puts "- `OCR` is populated"
  file.puts "- `Summary` is generated from OCR text"
  file.puts "- `Privacy preview` contains tokenized output"
  file.puts
  file.puts "## Share Pack Checklist"
  file.puts
  if published_media
    file.puts "- published screenshot asset: [intelligent-camera-success.png](../Assets/Flagship-Demo/intelligent-camera-success.png)"
    file.puts "- published recording asset: [intelligent-camera-run.mp4](../Assets/Flagship-Demo/intelligent-camera-run.mp4)"
    file.puts "- published caption asset: [caption.txt](../Assets/Flagship-Demo/caption.txt)"
  else
    file.puts "- one screenshot showing `Top labels`, `OCR`, `Summary`, and `Privacy preview` together"
    file.puts "- one 15-30 second screen recording from app launch to `Analyze Frame` success"
    file.puts "- one short caption: `Vision -> NLP -> Privacy in one Apple-native Swift package workflow`"
  end
  file.puts "- one proof link set: [Showcase](../Showcase.md), [Public Proof Status](Public-Proof-Status.md), [Latest Release Proof](Latest-Release-Proof.md)"
  file.puts
  file.puts "## Claim Boundaries"
  file.puts
  file.puts "- do not present simulator runs as mobile release evidence"
  file.puts "- do not claim category leadership from this demo alone"
  file.puts "- do not claim best-in-class benchmark performance against external competitors without current comparative proof"
end

puts "Flagship demo pack generated at #{output_path}"
RUBY
