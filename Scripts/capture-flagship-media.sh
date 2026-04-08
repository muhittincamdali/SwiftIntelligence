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

struct FlagshipMediaSnapshotView: View {
    let model: IntelligentCameraModel
    let headline: String
    let eyebrow: String
    let accent: Color

    var body: some View {
        HStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(eyebrow.uppercased())
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(accent)

                    Text(headline)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.primary)

                    Text("Vision -> NLP -> Privacy in one Apple-native Swift package workflow")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.secondary)
                }

                PreviewImageView(image: model.previewImage)
                    .frame(height: 360)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(accent.opacity(0.2), lineWidth: 1.5)
                    )

                HStack(spacing: 12) {
                    statusPill(title: "Status", value: model.status, tint: accent)
                    statusPill(title: "Objects", value: "\(model.objectCount)", tint: .green)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 14) {
                detailCard(title: "Top labels", value: model.classificationLabels)
                detailCard(title: "OCR", value: model.detectedText)
                detailCard(title: "Summary", value: model.summaryText)
                detailCard(title: "Privacy preview", value: model.redactedPreview ?? "-")
            }
            .frame(width: 410)
        }
        .padding(40)
    }

    private func statusPill(title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(Color.secondary)
            Text(value)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.primary)
                .lineLimit(2)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(tint.opacity(0.12))
        )
    }

    private func detailCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(Color.secondary)

            Text(value)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundStyle(Color.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.9))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.blue.opacity(0.08), lineWidth: 1)
        )
    }
}

@main
struct FlagshipMediaRenderer {
    static func main() async throws {
        let directory = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
        let initialPath = directory.appendingPathComponent("initial.png")
        let finalPath = directory.appendingPathComponent("final.png")

        let initialModel = IntelligentCameraModel()
        initialModel.refreshSample()
        try await render(
            FlagshipMediaSnapshotView(
                model: initialModel,
                headline: "Flagship path ready to analyze",
                eyebrow: "SwiftIntelligence Demo",
                accent: .blue
            ),
            to: initialPath
        )

        let finalModel = IntelligentCameraModel()
        await finalModel.runAutomationAnalysis()
        guard finalModel.status == "Vision -> NLP -> Privacy zinciri tamamlandi" else {
            throw NSError(domain: "FlagshipMediaRenderer", code: 1, userInfo: [NSLocalizedDescriptionKey: "Flagship analysis did not complete successfully."])
        }
        try await render(
            FlagshipMediaSnapshotView(
                model: finalModel,
                headline: "Release-grade flagship proof path",
                eyebrow: "Real demo result",
                accent: .orange
            ),
            to: finalPath
        )
    }

    @MainActor
    private static func render<Content: View>(_ view: Content, to url: URL) async throws {
        let content = ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.96, green: 0.97, blue: 1.0),
                    Color(red: 1.0, green: 0.96, blue: 0.93),
                    Color(red: 0.93, green: 0.97, blue: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(.white.opacity(0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .stroke(Color.blue.opacity(0.14), lineWidth: 1.5)
                )
                .padding(28)

            view
                .padding(40)
        }
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
