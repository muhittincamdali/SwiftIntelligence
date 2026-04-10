#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ASSET_DIR="${1:-$ROOT_DIR/Documentation/Assets/SmartTranslator-Demo}"
STATUS_README_PATH="${2:-$ASSET_DIR/README.md}"

if [[ "$ASSET_DIR" != /* ]]; then
  ASSET_DIR="$ROOT_DIR/$ASSET_DIR"
fi

if [[ "$STATUS_README_PATH" != /* ]]; then
  STATUS_README_PATH="$ROOT_DIR/$STATUS_README_PATH"
fi

mkdir -p "$ASSET_DIR"

if [[ ! -f "$STATUS_README_PATH" ]]; then
  echo "Missing SmartTranslator media README: $STATUS_README_PATH" >&2
  exit 1
fi

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "ffmpeg is required to encode SmartTranslator demo video." >&2
  exit 1
fi

TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/swiftintelligence-smarttranslator-media.XXXXXX")"
trap 'rm -rf "$TEMP_DIR"' EXIT

cat > "$TEMP_DIR/Package.swift" <<EOF
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwiftIntelligenceSmartTranslatorMediaCapture",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "SmartTranslatorMediaRenderer",
            targets: ["SmartTranslatorMediaRenderer"]
        )
    ],
    dependencies: [
        .package(path: "$ROOT_DIR")
    ],
    targets: [
        .executableTarget(
            name: "SmartTranslatorMediaRenderer",
            dependencies: [
                .product(name: "SwiftIntelligenceCore", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligenceNLP", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligencePrivacy", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligenceSpeech", package: "SwiftIntelligence")
            ],
            swiftSettings: [
                .define("SMARTTRANSLATOR_MEDIA_RENDERER")
            ]
        )
    ]
)
EOF

mkdir -p "$TEMP_DIR/Sources/SmartTranslatorMediaRenderer"
cp "$ROOT_DIR/Examples/DemoApps/SmartTranslator/SmartTranslatorApp.swift" "$TEMP_DIR/Sources/SmartTranslatorMediaRenderer/SmartTranslatorApp.swift"

cat > "$TEMP_DIR/Sources/SmartTranslatorMediaRenderer/Renderer.swift" <<'EOF'
import AppKit
import Foundation
import SwiftUI
import SwiftIntelligenceNLP
import SwiftIntelligencePrivacy
import SwiftIntelligenceSpeech

struct SmartTranslatorSnapshotView: View {
    let model: SmartTranslatorModel
    let headline: String
    let eyebrow: String
    let accent: Color

    var body: some View {
        HStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(eyebrow.uppercased())
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(accent)

                    Text(headline)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.primary)

                    Text("NLP -> Privacy -> Speech in one maintained Swift package path")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.secondary)
                }

                detailCard(title: "Input", value: model.sourceText)
                detailCard(title: "Translated output", value: model.translatedText)
                detailCard(title: "Summary", value: model.summaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 14) {
                statusPill(title: "Detected", value: model.detectedLanguage, tint: accent)
                statusPill(title: "Keywords", value: model.keywordsText, tint: .green)
                statusPill(title: "Speech", value: model.speechStatus, tint: .purple)
                detailCard(title: "Server preview", value: model.redactedPreview ?? "-")
                detailCard(title: "Translation note", value: model.translationNote ?? "No placeholder warning")
            }
            .frame(width: 420)
        }
        .padding(42)
    }

    private func statusPill(title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(Color.secondary)

            Text(value)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
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
struct SmartTranslatorMediaRenderer {
    static func main() async throws {
        let directory = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
        let initialPath = directory.appendingPathComponent("initial.png")
        let finalPath = directory.appendingPathComponent("final.png")

        let initialModel = await MainActor.run { SmartTranslatorModel() }
        try await render(
            SmartTranslatorSnapshotView(
                model: initialModel,
                headline: "Text-first secondary workflow",
                eyebrow: "SwiftIntelligence Demo",
                accent: .blue
            ),
            to: initialPath
        )

        let finalModel = await MainActor.run { SmartTranslatorModel() }
        try await populateFinalState(on: finalModel)

        try await render(
            SmartTranslatorSnapshotView(
                model: finalModel,
                headline: "Language analysis with privacy preprocessing",
                eyebrow: "Real demo result",
                accent: .orange
            ),
            to: finalPath
        )
    }

    private static func populateFinalState(on model: SmartTranslatorModel) async throws {
        let sourceText = await MainActor.run { model.sourceText.trimmingCharacters(in: .whitespacesAndNewlines) }
        let sourceLanguage = await MainActor.run { model.sourceLanguage }
        let targetLanguage = await MainActor.run { model.targetLanguage }

        let tokenizer = PrivacyTokenizer()
        let tokenized = try await tokenizer.tokenize(
            sourceText,
            context: TokenizationContext(
                purpose: .analytics,
                sensitivity: .medium,
                retentionPolicy: .temporary
            )
        )

        let analysis = try await NLPEngine.shared.analyze(text: sourceText, options: .basic)
        let summary = try await NLPEngine.shared.summarizeText(text: sourceText, maxSentences: 2)
        let translation = try await NLPEngine.shared.translateText(
            text: sourceText,
            from: sourceLanguage.nlLanguage,
            to: targetLanguage.nlLanguage
        )
        let keywords = (analysis.analysisResults["keywords"] as? [Keyword] ?? []).prefix(5).map(\.word).joined(separator: ", ")
        let availableVoices = await MainActor.run {
            SpeechEngine.availableVoices(for: targetLanguage.speechCode)
        }
        let speechStatus = availableVoices.isEmpty
            ? "Hazir"
            : "\(translation.translatedText.count) karakter seslendirilmeye hazir"

        await MainActor.run {
            model.detectedLanguage = analysis.detectedLanguage.rawValue
            model.summaryText = summary.summary
            model.keywordsText = keywords.isEmpty ? "-" : keywords
            model.redactedPreview = tokenized.tokens.first
            model.translatedText = translation.translatedText
            model.translationNote = translation.confidence == 0
                ? "Mevcut translation API placeholder durumunda; demo gercek modul cagrisi yapiyor ama backend/model entegrasyonu henuz tamamli degil."
                : nil
            model.speechStatus = speechStatus
            model.errorMessage = nil
            model.isProcessing = false
        }
    }

    @MainActor
    private static func render<Content: View>(_ view: Content, to url: URL) async throws {
        let content = ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.96, green: 0.97, blue: 1.0),
                    Color(red: 0.94, green: 0.98, blue: 0.95),
                    Color(red: 1.0, green: 0.96, blue: 0.94)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(.white.opacity(0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .stroke(Color.orange.opacity(0.14), lineWidth: 1.5)
                )
                .padding(28)

            view
                .padding(40)
        }
        .frame(width: 1280, height: 960)

        let renderer = ImageRenderer(content: content)
        renderer.scale = 2

        guard let image = renderer.nsImage else {
            throw NSError(domain: "SmartTranslatorMediaRenderer", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not render SmartTranslator view to image."])
        }

        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            throw NSError(domain: "SmartTranslatorMediaRenderer", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not encode SmartTranslator PNG data."])
        }

        try pngData.write(to: url)
    }
}
EOF

echo "Building SmartTranslator media renderer..."
swift build --package-path "$TEMP_DIR" --product SmartTranslatorMediaRenderer >/dev/null

echo "Rendering SmartTranslator media frames..."
swift run --skip-build --package-path "$TEMP_DIR" SmartTranslatorMediaRenderer "$TEMP_DIR" >/dev/null

cat > "$TEMP_DIR/caption.txt" <<'EOF'
NLP -> Privacy -> Speech in one maintained Swift package workflow
EOF

echo "Encoding SmartTranslator demo video..."
ffmpeg -y \
  -loop 1 -t 2 -i "$TEMP_DIR/initial.png" \
  -loop 1 -t 4 -i "$TEMP_DIR/final.png" \
  -filter_complex "[0:v]scale=1280:960,format=yuv420p[v0];[1:v]scale=1280:960,format=yuv420p[v1];[v0][v1]concat=n=2:v=1:a=0,format=yuv420p[v]" \
  -map "[v]" \
  -movflags +faststart \
  "$TEMP_DIR/smarttranslator-run.mp4" >/dev/null 2>&1

cp "$TEMP_DIR/final.png" "$ASSET_DIR/smarttranslator-success.png"
cp "$TEMP_DIR/smarttranslator-run.mp4" "$ASSET_DIR/smarttranslator-run.mp4"
cp "$TEMP_DIR/caption.txt" "$ASSET_DIR/caption.txt"

ruby - "$STATUS_README_PATH" <<'RUBY'
path = ARGV[0]
content = File.read(path)
updated = content.sub("Current status: `not-published`", "Current status: `published`")
File.write(path, updated)
RUBY

echo "SmartTranslator media captured to $ASSET_DIR"
