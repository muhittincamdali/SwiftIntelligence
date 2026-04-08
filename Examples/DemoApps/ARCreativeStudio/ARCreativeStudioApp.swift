import SwiftUI
import SwiftIntelligenceCore
import SwiftIntelligenceNLP
import SwiftIntelligenceVision
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

@main
struct ARCreativeStudioApp: App {
    var body: some Scene {
        WindowGroup {
            CreativeStudioScreen()
        }
    }
}

struct CreativeStudioScreen: View {
    @StateObject private var model = CreativeStudioModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    CreativeBoardPreview(image: model.boardImage)
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 22))

                    HStack {
                        Button("Analyze Board", action: model.analyzeBoard)
                            .buttonStyle(.borderedProminent)
                            .disabled(model.isProcessing)

                        Button("Refresh Board", action: model.refreshBoard)
                            .buttonStyle(.bordered)
                            .disabled(model.isProcessing)

                        if model.isProcessing {
                            ProgressView()
                        }
                    }

                    diagnostics
                    suggestions
                }
                .padding()
            }
            .navigationTitle("AR Creative Studio")
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

    private var diagnostics: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Board Diagnostics")
                .font(.headline)

            LabeledContent("Labels", value: model.labelsText)
            LabeledContent("Object count", value: "\(model.objectCount)")
            LabeledContent("OCR", value: model.ocrText)
            LabeledContent("Creative brief", value: model.briefSummary)
        }
        .font(.caption)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var suggestions: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Creative Suggestions")
                .font(.headline)

            ForEach(model.suggestions, id: \.self) { suggestion in
                Text("• \(suggestion)")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

@MainActor
final class CreativeStudioModel: ObservableObject {
    @Published var boardImage = CreativeBoardFactory.makeImage()
    @Published var labelsText = "-"
    @Published var objectCount = 0
    @Published var ocrText = "-"
    @Published var briefSummary = "-"
    @Published var suggestions: [String] = ["Analyze the board to generate composition suggestions."]
    @Published var errorMessage: String?
    @Published var isProcessing = false

    private let vision = VisionEngine.shared
    private let nlp = NLPEngine.shared

    init() {
        SwiftIntelligenceCore.shared.configure(with: .production)
        Task { try? await vision.initialize() }
    }

    func refreshBoard() {
        boardImage = CreativeBoardFactory.makeImage()
    }

    func analyzeBoard() {
        Task { await runAnalysis() }
    }

    private func runAnalysis() async {
        isProcessing = true
        defer { isProcessing = false }

        do {
            try await vision.initialize()

            let classification = try await vision.classifyImage(boardImage, options: .default)
            labelsText = classification.classifications.prefix(3).map(\.label).joined(separator: ", ")

            let detection = try await vision.detectObjects(in: boardImage, options: .default)
            objectCount = detection.detectedObjects.count

            let document = try await vision.analyzeDocument(boardImage, options: .default)
            ocrText = document.documentText.isEmpty ? "-" : document.documentText

            let analysisSource = [labelsText, ocrText].filter { $0 != "-" }.joined(separator: ". ")
            if analysisSource.isEmpty {
                briefSummary = "No machine-readable brief extracted."
                suggestions = [
                    "Add textual anchors or stronger focal objects.",
                    "Increase contrast between foreground and background."
                ]
                return
            }

            let summary = try await nlp.summarizeText(text: analysisSource, maxSentences: 1)
            briefSummary = summary.summary

            let keywords = nlp.extractKeywords(text: analysisSource, maxCount: 4).map(\.word)
            suggestions = buildSuggestions(from: keywords, objectCount: detection.detectedObjects.count)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func buildSuggestions(from keywords: [String], objectCount: Int) -> [String] {
        let joinedKeywords = keywords.joined(separator: ", ")
        let joined = joinedKeywords.isEmpty ? "scene, product, motion" : joinedKeywords
        return [
            "Use \(joined) as the visual story anchors.",
            objectCount > 2
                ? "Scene is busy; isolate one hero object before layering effects."
                : "Scene is sparse; add one bold foreground subject for depth.",
            "Convert OCR brief into a production checklist before moving to richer AR or generation layers."
        ]
    }
}

struct CreativeBoardPreview: View {
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

enum CreativeBoardFactory {
    static func makeImage() -> PlatformImage {
        #if canImport(UIKit)
        let size = CGSize(width: 1280, height: 820)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.systemTeal.withAlphaComponent(0.18).setFill()
            context.cgContext.fill(CGRect(origin: .zero, size: size))

            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 58),
                .foregroundColor: UIColor.label
            ]
            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 34),
                .foregroundColor: UIColor.secondaryLabel
            ]

            "Creative Board".draw(in: CGRect(x: 80, y: 90, width: 500, height: 80), withAttributes: titleAttributes)
            "Campaign: Summer launch / neon product stage".draw(in: CGRect(x: 80, y: 260, width: 860, height: 50), withAttributes: bodyAttributes)
            "Need motion depth + clear call to action".draw(in: CGRect(x: 80, y: 340, width: 860, height: 50), withAttributes: bodyAttributes)

            UIColor.systemPink.setFill()
            context.cgContext.fillEllipse(in: CGRect(x: 900, y: 210, width: 220, height: 220))
            UIColor.systemIndigo.setFill()
            context.cgContext.fill(CGRect(x: 760, y: 500, width: 320, height: 120))
        }
        #elseif canImport(AppKit)
        let size = CGSize(width: 1280, height: 820)
        let image = NSImage(size: size)
        image.lockFocus()

        NSColor.systemTeal.withAlphaComponent(0.18).setFill()
        NSBezierPath(rect: CGRect(origin: .zero, size: size)).fill()

        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.boldSystemFont(ofSize: 58),
            .foregroundColor: NSColor.labelColor
        ]
        let bodyAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 34),
            .foregroundColor: NSColor.secondaryLabelColor
        ]

        "Creative Board".draw(in: CGRect(x: 80, y: 650, width: 500, height: 80), withAttributes: titleAttributes)
        "Campaign: Summer launch / neon product stage".draw(in: CGRect(x: 80, y: 500, width: 860, height: 50), withAttributes: bodyAttributes)
        "Need motion depth + clear call to action".draw(in: CGRect(x: 80, y: 420, width: 860, height: 50), withAttributes: bodyAttributes)

        NSColor.systemPink.setFill()
        NSBezierPath(ovalIn: CGRect(x: 900, y: 390, width: 220, height: 220)).fill()
        NSColor.systemIndigo.setFill()
        NSBezierPath(rect: CGRect(x: 760, y: 180, width: 320, height: 120)).fill()

        image.unlockFocus()
        return image
        #endif
    }
}
