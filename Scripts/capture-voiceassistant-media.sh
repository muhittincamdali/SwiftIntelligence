#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ASSET_DIR="${1:-$ROOT_DIR/Documentation/Assets/VoiceAssistant-Demo}"
STATUS_README_PATH="${2:-$ASSET_DIR/README.md}"

if [[ "$ASSET_DIR" != /* ]]; then
  ASSET_DIR="$ROOT_DIR/$ASSET_DIR"
fi

if [[ "$STATUS_README_PATH" != /* ]]; then
  STATUS_README_PATH="$ROOT_DIR/$STATUS_README_PATH"
fi

mkdir -p "$ASSET_DIR"

if [[ ! -f "$STATUS_README_PATH" ]]; then
  echo "Missing VoiceAssistant media README: $STATUS_README_PATH" >&2
  exit 1
fi

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "ffmpeg is required to encode VoiceAssistant demo video." >&2
  exit 1
fi

TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/swiftintelligence-voiceassistant-media.XXXXXX")"
trap 'rm -rf "$TEMP_DIR"' EXIT

cat > "$TEMP_DIR/Package.swift" <<EOF
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwiftIntelligenceVoiceAssistantMediaCapture",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "VoiceAssistantMediaRenderer",
            targets: ["VoiceAssistantMediaRenderer"]
        )
    ],
    dependencies: [
        .package(path: "$ROOT_DIR")
    ],
    targets: [
        .executableTarget(
            name: "VoiceAssistantMediaRenderer",
            dependencies: [
                .product(name: "SwiftIntelligenceCore", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligenceNLP", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligencePrivacy", package: "SwiftIntelligence"),
                .product(name: "SwiftIntelligenceSpeech", package: "SwiftIntelligence")
            ],
            swiftSettings: [
                .define("VOICEASSISTANT_MEDIA_RENDERER")
            ]
        )
    ]
)
EOF

mkdir -p "$TEMP_DIR/Sources/VoiceAssistantMediaRenderer"
cp "$ROOT_DIR/Examples/DemoApps/VoiceAssistant/VoiceAssistantApp.swift" "$TEMP_DIR/Sources/VoiceAssistantMediaRenderer/VoiceAssistantApp.swift"

cat > "$TEMP_DIR/Sources/VoiceAssistantMediaRenderer/Renderer.swift" <<'EOF'
import AppKit
import Foundation
import SwiftUI
import SwiftIntelligenceNLP
import SwiftIntelligencePrivacy
import SwiftIntelligenceSpeech

struct VoiceAssistantSnapshotView: View {
    let model: VoiceAssistantModel
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

                    Text("NLP -> Privacy -> Speech in an assistant-style Apple-native workflow")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.secondary)
                }

                detailCard(title: "Command", value: model.commandText)
                detailCard(title: "Assistant response", value: model.responseText)
                detailCard(title: "Summary", value: model.summaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 14) {
                statusPill(title: "Intent", value: model.intentLabel, tint: accent)
                statusPill(title: "Detected language", value: model.detectedLanguage, tint: .green)
                statusPill(title: "Speech", value: model.speechStatus, tint: .purple)
                detailCard(title: "Redacted", value: model.redactedPreview ?? "-")
                detailCard(title: "History", value: model.history.first?.response ?? "No history yet")
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
struct VoiceAssistantMediaRenderer {
    static func main() async throws {
        let directory = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
        let initialPath = directory.appendingPathComponent("initial.png")
        let finalPath = directory.appendingPathComponent("final.png")

        let initialModel = await MainActor.run { VoiceAssistantModel() }
        try await render(
            VoiceAssistantSnapshotView(
                model: initialModel,
                headline: "Assistant-style secondary workflow",
                eyebrow: "SwiftIntelligence Demo",
                accent: .blue
            ),
            to: initialPath
        )

        let finalModel = await MainActor.run { VoiceAssistantModel() }
        try await populateFinalState(on: finalModel)

        try await render(
            VoiceAssistantSnapshotView(
                model: finalModel,
                headline: "Assistant response with privacy-aware preprocessing",
                eyebrow: "Real demo result",
                accent: .orange
            ),
            to: finalPath
        )
    }

    private static func populateFinalState(on model: VoiceAssistantModel) async throws {
        let commandText = await MainActor.run { model.commandText.trimmingCharacters(in: .whitespacesAndNewlines) }
        let privacyMode = await MainActor.run { model.privacyMode }

        let analysis = try await NLPEngine.shared.analyze(text: commandText, options: .comprehensive)
        let summary = try await NLPEngine.shared.summarizeText(text: commandText, maxSentences: 1)
        let entities = analysis.analysisResults["entities"] as? [NamedEntity] ?? []
        let keywords = analysis.analysisResults["keywords"] as? [Keyword] ?? []
        let intent = inferIntent(from: commandText, keywords: keywords, entities: entities)

        var redactedPreview: String?
        if privacyMode {
            let tokenized = try await PrivacyTokenizer().tokenize(
                commandText,
                context: TokenizationContext(
                    purpose: .analytics,
                    sensitivity: .high,
                    retentionPolicy: .temporary
                )
            )
            redactedPreview = tokenized.tokens.first
        }
        let finalRedactedPreview = redactedPreview

        let response = buildResponse(
            intent: intent,
            summary: summary.summary,
            entities: entities,
            keywords: keywords
        )
        let availableVoices = await MainActor.run {
            SpeechEngine.availableVoices(for: analysis.detectedLanguage.rawValue.hasPrefix("tr") ? "tr-TR" : "en-US")
        }
        let speechStatus = availableVoices.isEmpty
            ? "Hazir"
            : "\(response.count) karakter seslendirilmeye hazir"

        await MainActor.run {
            model.detectedLanguage = analysis.detectedLanguage.rawValue
            model.summaryText = summary.summary
            model.intentLabel = intent
            model.redactedPreview = finalRedactedPreview
            model.responseText = response
            model.speechStatus = speechStatus
            model.errorMessage = nil
            model.isProcessing = false
            model.history = [AssistantHistoryItem(command: commandText, response: response)]
        }
    }

    private static func inferIntent(from text: String, keywords: [Keyword], entities: [NamedEntity]) -> String {
        let lowercased = text.lowercased()
        let keywordSet = Set(keywords.map(\.word))
        let entityTypes = Set(entities.map(\.type))

        if lowercased.contains("hatirlat") || entityTypes.contains(.date) {
            return "Reminder"
        }
        if lowercased.contains("ara") || lowercased.contains("call") {
            return "Call"
        }
        if lowercased.contains("ozet") || lowercased.contains("summarize") {
            return "Summarize"
        }
        if keywordSet.contains("toplanti") || keywordSet.contains("meeting") {
            return "Schedule"
        }
        return "General Assistant"
    }

    private static func buildResponse(
        intent: String,
        summary: String,
        entities: [NamedEntity],
        keywords: [Keyword]
    ) -> String {
        let notableEntities = entities.prefix(3).map(\.text).joined(separator: ", ")
        let notableKeywords = keywords.prefix(3).map(\.word).joined(separator: ", ")
        let safeEntities = notableEntities.isEmpty ? "-" : notableEntities
        let safeKeywords = notableKeywords.isEmpty ? "-" : notableKeywords

        switch intent {
        case "Reminder":
            return "Hatirlatma akisi algilandi. Ozet: \(summary). Kritik varliklar: \(safeEntities)."
        case "Call":
            return "Iletisim niyeti algilandi. Kisi veya hedef: \(safeEntities). Komut ozeti: \(summary)"
        case "Summarize":
            return "Ozet modu hazir. Kisaltilmis sonuc: \(summary)"
        case "Schedule":
            return "Takvimleme niyeti algilandi. Ana sinyaller: \(safeKeywords). Ozet: \(summary)"
        default:
            return "Komut analiz edildi. Ozet: \(summary). Ana kelimeler: \(safeKeywords)."
        }
    }

    @MainActor
    private static func render<Content: View>(_ view: Content, to url: URL) async throws {
        let content = ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.96, green: 0.97, blue: 1.0),
                    Color(red: 0.95, green: 0.96, blue: 1.0),
                    Color(red: 0.99, green: 0.95, blue: 0.97)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(.white.opacity(0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .stroke(Color.purple.opacity(0.14), lineWidth: 1.5)
                )
                .padding(28)

            view
                .padding(40)
        }
        .frame(width: 1280, height: 960)

        let renderer = ImageRenderer(content: content)
        renderer.scale = 2

        guard let image = renderer.nsImage else {
            throw NSError(domain: "VoiceAssistantMediaRenderer", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not render VoiceAssistant view to image."])
        }

        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            throw NSError(domain: "VoiceAssistantMediaRenderer", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not encode VoiceAssistant PNG data."])
        }

        try pngData.write(to: url)
    }
}
EOF

echo "Building VoiceAssistant media renderer..."
swift build --package-path "$TEMP_DIR" --product VoiceAssistantMediaRenderer >/dev/null

echo "Rendering VoiceAssistant media frames..."
swift run --skip-build --package-path "$TEMP_DIR" VoiceAssistantMediaRenderer "$TEMP_DIR" >/dev/null

cat > "$TEMP_DIR/caption.txt" <<'EOF'
NLP -> Privacy -> Speech in an assistant-style Apple-native workflow
EOF

echo "Encoding VoiceAssistant demo video..."
ffmpeg -y \
  -loop 1 -t 2 -i "$TEMP_DIR/initial.png" \
  -loop 1 -t 4 -i "$TEMP_DIR/final.png" \
  -filter_complex "[0:v]scale=1280:960,format=yuv420p[v0];[1:v]scale=1280:960,format=yuv420p[v1];[v0][v1]concat=n=2:v=1:a=0,format=yuv420p[v]" \
  -map "[v]" \
  -movflags +faststart \
  "$TEMP_DIR/voiceassistant-run.mp4" >/dev/null 2>&1

cp "$TEMP_DIR/final.png" "$ASSET_DIR/voiceassistant-success.png"
cp "$TEMP_DIR/voiceassistant-run.mp4" "$ASSET_DIR/voiceassistant-run.mp4"
cp "$TEMP_DIR/caption.txt" "$ASSET_DIR/caption.txt"

ruby - "$STATUS_README_PATH" <<'RUBY'
path = ARGV[0]
content = File.read(path)
updated = content.sub("Current status: `not-published`", "Current status: `published`")
File.write(path, updated)
RUBY

echo "VoiceAssistant media captured to $ASSET_DIR"
