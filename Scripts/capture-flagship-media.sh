#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ASSET_DIR="${1:-$ROOT_DIR/Documentation/Assets/Flagship-Demo}"
STATUS_README_PATH="${2:-$ASSET_DIR/README.md}"

if [[ "$ASSET_DIR" != /* ]]; then
  ASSET_DIR="$ROOT_DIR/$ASSET_DIR"
fi

if [[ "$STATUS_README_PATH" != /* ]]; then
  STATUS_README_PATH="$ROOT_DIR/$STATUS_README_PATH"
fi

mkdir -p "$ASSET_DIR"

if [[ ! -f "$STATUS_README_PATH" ]]; then
  echo "Missing flagship media README: $STATUS_README_PATH" >&2
  exit 1
fi

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "ffmpeg is required to encode flagship demo video." >&2
  exit 1
fi

TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/swiftintelligence-flagship-media.XXXXXX")"
trap 'rm -rf "$TEMP_DIR"' EXIT

cat > "$TEMP_DIR/Package.swift" <<EOF
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwiftIntelligenceFlagshipMediaCapture",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "FlagshipMediaRenderer",
            targets: ["FlagshipMediaRenderer"]
        )
    ],
    dependencies: [
        .package(path: "$ROOT_DIR")
    ],
    targets: [
        .executableTarget(
            name: "FlagshipMediaRenderer",
            dependencies: [
                .product(name: "SwiftIntelligenceCore", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligenceNLP", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligenceVision", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligencePrivacy", package: "SwiftIntelligence")
            ],
            swiftSettings: [
                .define("FLAGSHIP_MEDIA_RENDERER")
            ]
        )
    ]
)
EOF

mkdir -p "$TEMP_DIR/Sources/FlagshipMediaRenderer"
cp "$ROOT_DIR/Examples/DemoApps/IntelligentCamera/IntelligentCameraApp.swift" "$TEMP_DIR/Sources/FlagshipMediaRenderer/IntelligentCameraApp.swift"

cat > "$TEMP_DIR/Sources/FlagshipMediaRenderer/Renderer.swift" <<'EOF'
import AppKit
import Foundation
import SwiftUI
import SwiftIntelligenceCore

@main
struct FlagshipMediaRenderer {
    static func main() async throws {
        let directory = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
        let initialPath = directory.appendingPathComponent("initial.png")
        let finalPath = directory.appendingPathComponent("final.png")

        let initialModel = IntelligentCameraModel()
        initialModel.refreshSample()
        try await render(CameraDemoScreen(model: initialModel), to: initialPath)

        let finalModel = IntelligentCameraModel()
        await finalModel.runAutomationAnalysis()
        guard finalModel.status == "Vision -> NLP -> Privacy zinciri tamamlandi" else {
            throw NSError(domain: "FlagshipMediaRenderer", code: 1, userInfo: [NSLocalizedDescriptionKey: "Flagship analysis did not complete successfully."])
        }
        try await render(CameraDemoScreen(model: finalModel), to: finalPath)
    }

    @MainActor
    private static func render(_ view: CameraDemoScreen, to url: URL) async throws {
        let content = view
            .frame(width: 1280, height: 960)

        let renderer = ImageRenderer(content: content)
        renderer.scale = 2

        guard let image = renderer.nsImage else {
            throw NSError(domain: "FlagshipMediaRenderer", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not render SwiftUI view to image."])
        }

        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            throw NSError(domain: "FlagshipMediaRenderer", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not encode PNG data."])
        }

        try pngData.write(to: url)
    }
}
EOF

echo "Building render-based flagship media target..."
swift build --package-path "$TEMP_DIR" --product FlagshipMediaRenderer >/dev/null

echo "Rendering flagship media frames..."
swift run --skip-build --package-path "$TEMP_DIR" FlagshipMediaRenderer "$TEMP_DIR" >/dev/null

cat > "$TEMP_DIR/caption.txt" <<'EOF'
Vision -> NLP -> Privacy in one Apple-native Swift package workflow
EOF

echo "Encoding flagship demo video..."
ffmpeg -y \
  -loop 1 -t 2 -i "$TEMP_DIR/initial.png" \
  -loop 1 -t 4 -i "$TEMP_DIR/final.png" \
  -filter_complex "[0:v]scale=1280:960,format=yuv420p[v0];[1:v]scale=1280:960,format=yuv420p[v1];[v0][v1]concat=n=2:v=1:a=0,format=yuv420p[v]" \
  -map "[v]" \
  -movflags +faststart \
  "$TEMP_DIR/intelligent-camera-run.mp4" >/dev/null 2>&1

cp "$TEMP_DIR/final.png" "$ASSET_DIR/intelligent-camera-success.png"
cp "$TEMP_DIR/intelligent-camera-run.mp4" "$ASSET_DIR/intelligent-camera-run.mp4"
cp "$TEMP_DIR/caption.txt" "$ASSET_DIR/caption.txt"

ruby - "$STATUS_README_PATH" <<'RUBY'
path = ARGV[0]
content = File.read(path)
updated = content.sub("Current status: `not-published`", "Current status: `published`")
File.write(path, updated)
RUBY

echo "Flagship media captured to $ASSET_DIR"
