import SwiftUI
import SwiftIntelligenceCore
import SwiftIntelligenceML
import SwiftIntelligenceNLP
import SwiftIntelligencePrivacy
import SwiftIntelligenceVision
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

@main
struct PersonalAITutorApp: App {
    var body: some Scene {
        WindowGroup {
            TutorScreen()
        }
    }
}

struct TutorScreen: View {
    @StateObject private var model = PersonalTutorModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    lessonCard
                    noteCard
                    controls
                    resultsCard
                }
                .padding()
            }
            .navigationTitle("Personal AI Tutor")
        }
        .alert("Hata", isPresented: Binding(
            get: { model.errorMessage != nil },
            set: { _ in model.errorMessage = nil }
        )) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(model.errorMessage ?? "")
        }
    }

    private var lessonCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Lesson Input")
                .font(.headline)

            TextEditor(text: $model.lessonText)
                .frame(minHeight: 160)
                .padding(8)
                .background(Color.secondary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14))

            Stepper("Study minutes: \(model.studyMinutes)", value: $model.studyMinutes, in: 10 ... 120, step: 5)
            Stepper("Practice score: \(model.practiceScore)%", value: $model.practiceScore, in: 20 ... 100, step: 5)
        }
    }

    private var noteCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Study Note Snapshot")
                .font(.headline)

            TutorNotePreview(image: model.noteImage)
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 18))

            Text("Synthetic note image keeps the example self-contained while still exercising the current Vision pipeline.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var controls: some View {
        HStack {
            Button("Analyze Lesson", action: model.analyzeLesson)
                .buttonStyle(.borderedProminent)
                .disabled(model.isProcessing)

            Button("Refresh Note", action: model.refreshNote)
                .buttonStyle(.bordered)
                .disabled(model.isProcessing)

            if model.isProcessing {
                ProgressView()
            }
        }
    }

    private var resultsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tutor Output")
                .font(.headline)

            LabeledContent("Summary", value: model.summaryText)
            LabeledContent("Keywords", value: model.keywordsText)
            LabeledContent("OCR", value: model.ocrText)
            LabeledContent("Recommended track", value: model.recommendedTrack)
            LabeledContent("Privacy preview", value: model.redactedPreview ?? "-")

            Text(model.feedbackText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color.secondary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .font(.caption)
    }
}

@MainActor
final class PersonalTutorModel: ObservableObject {
    @Published var lessonText = "Photosynthesis converts light energy into chemical energy. Chlorophyll absorbs light, and plants use carbon dioxide with water to produce glucose and oxygen."
    @Published var studyMinutes = 35
    @Published var practiceScore = 70
    @Published var summaryText = "-"
    @Published var keywordsText = "-"
    @Published var ocrText = "-"
    @Published var recommendedTrack = "-"
    @Published var feedbackText = "Awaiting analysis"
    @Published var redactedPreview: String?
    @Published var errorMessage: String?
    @Published var isProcessing = false
    @Published var noteImage = TutorNoteImageFactory.makeImage()

    private let nlp = NLPEngine.shared
    private let vision = VisionEngine.shared
    private let tokenizer = PrivacyTokenizer()

    init() {
        SwiftIntelligenceCore.shared.configure(with: .production)
        Task { try? await vision.initialize() }
    }

    func refreshNote() {
        noteImage = TutorNoteImageFactory.makeImage()
    }

    func analyzeLesson() {
        Task { await runAnalysis() }
    }

    private func runAnalysis() async {
        isProcessing = true
        defer { isProcessing = false }

        do {
            let text = lessonText.trimmingCharacters(in: .whitespacesAndNewlines)

            let analysis = try await nlp.analyze(text: text, options: .basic)
            let summary = try await nlp.summarizeText(text: text, maxSentences: 2)
            summaryText = summary.summary

            let keywords = analysis.analysisResults["keywords"] as? [Keyword] ?? []
            keywordsText = keywords.prefix(5).map(\.word).joined(separator: ", ")

            try await vision.initialize()
            let document = try await vision.analyzeDocument(noteImage, options: .default)
            ocrText = document.documentText.isEmpty ? "-" : document.documentText

            let tokenized = try await tokenizer.tokenize(
                text,
                context: TokenizationContext(
                    purpose: .analytics,
                    sensitivity: .medium,
                    retentionPolicy: .temporary
                )
            )
            redactedPreview = tokenized.tokens.first

            let track = try await predictLearningTrack()
            recommendedTrack = track.classificationResult ?? "balanced"
            feedbackText = buildFeedback(track: recommendedTrack, summary: summary.summary, ocrText: document.documentText)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func predictLearningTrack() async throws -> MLOutput {
        let engine = try await SwiftIntelligenceML()
        defer { Task { try? await engine.shutdown() } }

        let training = MLTrainingData(
            inputs: [
                MLInput(features: [20, 40]),
                MLInput(features: [35, 70]),
                MLInput(features: [60, 92])
            ],
            expectedOutputs: [
                MLOutput(prediction: [0], classificationResult: "intensive", confidence: 1),
                MLOutput(prediction: [1], classificationResult: "balanced", confidence: 1),
                MLOutput(prediction: [2], classificationResult: "advanced", confidence: 1)
            ]
        )

        _ = try await engine.train(modelID: "classification", with: training)
        return try await engine.predict(
            modelID: "classification",
            input: MLInput(
                features: [Double(studyMinutes), Double(practiceScore)],
                metadata: ["summary": summaryText]
            )
        )
    }

    private func buildFeedback(track: String, summary: String, ocrText: String) -> String {
        let noteSignal = ocrText.isEmpty ? "No note OCR" : "OCR note: \(String(ocrText.prefix(90)))"

        switch track {
        case "intensive":
            return "Intensive tekrar oneriliyor. Kisa hedefler belirle, sonra 10 soruluk hizli practice yap. \(noteSignal)"
        case "advanced":
            return "Advanced mod uygun. Ozetten sonra kavramlari kendi cumlelerinle yeniden yaz ve zor soru setine gec. \(noteSignal)"
        default:
            return "Balanced plan uygun. Ozet: \(summary). Ardindan orta zorlukta tekrar ve mini quiz uygula. \(noteSignal)"
        }
    }
}

struct TutorNotePreview: View {
    let image: PlatformImage

    var body: some View {
        #if canImport(UIKit)
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
        #elseif canImport(AppKit)
        Image(nsImage: image)
            .resizable()
            .scaledToFill()
        #endif
    }
}

enum TutorNoteImageFactory {
    static func makeImage() -> PlatformImage {
        #if canImport(UIKit)
        let size = CGSize(width: 1200, height: 720)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.systemYellow.withAlphaComponent(0.15).setFill()
            context.cgContext.fill(CGRect(origin: .zero, size: size))

            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 54),
                .foregroundColor: UIColor.label
            ]
            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 34),
                .foregroundColor: UIColor.secondaryLabel
            ]

            "Study Notes".draw(in: CGRect(x: 80, y: 90, width: 400, height: 70), withAttributes: titleAttributes)
            "Photosynthesis -> glucose + oxygen".draw(in: CGRect(x: 80, y: 240, width: 800, height: 50), withAttributes: bodyAttributes)
            "Chlorophyll absorbs light".draw(in: CGRect(x: 80, y: 320, width: 700, height: 50), withAttributes: bodyAttributes)
            "Water + CO2 are required".draw(in: CGRect(x: 80, y: 400, width: 700, height: 50), withAttributes: bodyAttributes)
        }
        #elseif canImport(AppKit)
        let size = CGSize(width: 1200, height: 720)
        let image = NSImage(size: size)
        image.lockFocus()

        NSColor.systemYellow.withAlphaComponent(0.15).setFill()
        NSBezierPath(rect: CGRect(origin: .zero, size: size)).fill()

        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.boldSystemFont(ofSize: 54),
            .foregroundColor: NSColor.labelColor
        ]
        let bodyAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 34),
            .foregroundColor: NSColor.secondaryLabelColor
        ]

        "Study Notes".draw(in: CGRect(x: 80, y: 560, width: 400, height: 70), withAttributes: titleAttributes)
        "Photosynthesis -> glucose + oxygen".draw(in: CGRect(x: 80, y: 420, width: 800, height: 50), withAttributes: bodyAttributes)
        "Chlorophyll absorbs light".draw(in: CGRect(x: 80, y: 340, width: 700, height: 50), withAttributes: bodyAttributes)
        "Water + CO2 are required".draw(in: CGRect(x: 80, y: 260, width: 700, height: 50), withAttributes: bodyAttributes)

        image.unlockFocus()
        return image
        #endif
    }
}
