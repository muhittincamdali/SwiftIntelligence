import SwiftUI
import SwiftIntelligenceCore
import SwiftIntelligenceNLP
import SwiftIntelligencePrivacy
import SwiftIntelligenceVision
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

#if !FLAGSHIP_MEDIA_RENDERER
@main
struct IntelligentCameraApp: App {
    var body: some Scene {
        WindowGroup {
            CameraDemoScreen()
        }
    }
}
#endif

struct CameraDemoScreen: View {
    @StateObject private var model = IntelligentCameraModel()
    @State private var didTriggerAutomation = false

    @MainActor
    init() {
        _model = StateObject(wrappedValue: IntelligentCameraModel())
    }

    @MainActor
    init(model: IntelligentCameraModel) {
        _model = StateObject(wrappedValue: model)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    overviewCard

                    PreviewImageView(image: model.previewImage)
                        .frame(height: 280)
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                    HStack {
                        Button("Analyze Frame", action: model.analyzeSample)
                            .buttonStyle(.borderedProminent)
                            .disabled(model.isProcessing)

                        Button("Refresh Sample", action: model.refreshSample)
                            .buttonStyle(.bordered)
                            .disabled(model.isProcessing)

                        if model.isProcessing {
                            ProgressView()
                        }
                    }

                    diagnosticsCard
                }
                .padding()
            }
            .navigationTitle("Intelligent Camera")
        }
        .onAppear {
            guard !didTriggerAutomation else { return }
            guard ProcessInfo.processInfo.environment["SI_FLAGSHIP_AUTORUN"] == "1" else { return }
            didTriggerAutomation = true

            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 600_000_000)
                model.analyzeSample()
            }
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

    private var diagnosticsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Vision Diagnostics")
                .font(.headline)

            LabeledContent("Status", value: model.status)
            LabeledContent("Top labels", value: model.classificationLabels)
            LabeledContent("Object count", value: "\(model.objectCount)")
            LabeledContent("OCR", value: model.detectedText)
            LabeledContent("Summary", value: model.summaryText)
            LabeledContent("Privacy preview", value: model.redactedPreview ?? "-")
        }
        .font(.caption)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var overviewCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Flagship Flow")
                .font(.headline)

            Text("Pipeline: Vision -> NLP -> Privacy")
            Text("Sample frame: invoice text + meeting metadata")
            Text("Success signal: labels, OCR, summary, and tokenized privacy preview all populate")
        }
        .font(.caption)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

@MainActor
final class IntelligentCameraModel: ObservableObject {
    @Published var previewImage = SampleFrameFactory.makeImage()
    @Published var status = "Hazir"
    @Published var classificationLabels = "-"
    @Published var objectCount = 0
    @Published var detectedText = "-"
    @Published var summaryText = "-"
    @Published var redactedPreview: String?
    @Published var errorMessage: String?
    @Published var isProcessing = false

    private let visionEngine = VisionEngine.shared
    private let nlpEngine = NLPEngine.shared
    private let tokenizer = PrivacyTokenizer()

    init() {
        SwiftIntelligenceCore.shared.configure(with: .production)
        Task { try? await visionEngine.initialize() }
    }

    func refreshSample() {
        previewImage = SampleFrameFactory.makeImage()
        status = "Yeni ornek frame hazir"
    }

    func analyzeSample() {
        Task { await runAnalysis() }
    }

    func runAutomationAnalysis() async {
        await runAnalysis()
    }

    private func runAnalysis() async {
        isProcessing = true
        defer { isProcessing = false }

        do {
            try await visionEngine.initialize()

            let classification = try await visionEngine.classifyImage(previewImage, options: .default)
            classificationLabels = classification.classifications.prefix(3).map(\.label).joined(separator: ", ")

            let detections = try await visionEngine.detectObjects(in: previewImage, options: .default)
            objectCount = detections.detectedObjects.count

            let document = try await visionEngine.analyzeDocument(previewImage, options: .default)
            detectedText = document.documentText.isEmpty ? "-" : document.documentText

            if !document.documentText.isEmpty {
                let summary = try await nlpEngine.summarizeText(text: document.documentText, maxSentences: 2)
                summaryText = summary.summary

                let tokenized = try await tokenizer.tokenize(
                    document.documentText,
                    context: TokenizationContext(
                        purpose: .analytics,
                        sensitivity: .high,
                        retentionPolicy: .temporary
                    )
                )
                redactedPreview = tokenized.tokens.first
            } else {
                summaryText = "-"
                redactedPreview = nil
            }

            status = "Vision -> NLP -> Privacy zinciri tamamlandi"
        } catch {
            errorMessage = error.localizedDescription
            status = "Basarisiz"
        }
    }
}

struct PreviewImageView: View {
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

enum SampleFrameFactory {
    static func makeImage() -> PlatformImage {
        #if canImport(UIKit)
        let size = CGSize(width: 1200, height: 800)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.systemBackground.setFill()
            context.cgContext.fill(CGRect(origin: .zero, size: size))

            UIImage(systemName: "camera.viewfinder")?
                .withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
                .draw(in: CGRect(x: 80, y: 80, width: 180, height: 180))

            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 56),
                .foregroundColor: UIColor.label
            ]
            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 36),
                .foregroundColor: UIColor.secondaryLabel
            ]

            "SwiftIntelligence Camera Demo".draw(in: CGRect(x: 300, y: 110, width: 760, height: 80), withAttributes: titleAttributes)
            "Invoice total: 249 USD".draw(in: CGRect(x: 100, y: 340, width: 560, height: 50), withAttributes: bodyAttributes)
            "Meeting point: Istanbul".draw(in: CGRect(x: 100, y: 410, width: 560, height: 50), withAttributes: bodyAttributes)
            "Time: 10:30".draw(in: CGRect(x: 100, y: 480, width: 560, height: 50), withAttributes: bodyAttributes)
        }
        #elseif canImport(AppKit)
        let size = CGSize(width: 1200, height: 800)
        let image = NSImage(size: size)
        image.lockFocus()

        NSColor.textBackgroundColor.setFill()
        NSBezierPath(rect: CGRect(origin: .zero, size: size)).fill()

        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.boldSystemFont(ofSize: 56),
            .foregroundColor: NSColor.labelColor
        ]
        let bodyAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 36),
            .foregroundColor: NSColor.secondaryLabelColor
        ]

        NSImage(systemSymbolName: "camera.viewfinder", accessibilityDescription: nil)?
            .draw(in: CGRect(x: 80, y: 520, width: 180, height: 180))

        "SwiftIntelligence Camera Demo".draw(in: CGRect(x: 300, y: 560, width: 760, height: 80), withAttributes: titleAttributes)
        "Invoice total: 249 USD".draw(in: CGRect(x: 100, y: 340, width: 560, height: 50), withAttributes: bodyAttributes)
        "Meeting point: Istanbul".draw(in: CGRect(x: 100, y: 270, width: 560, height: 50), withAttributes: bodyAttributes)
        "Time: 10:30".draw(in: CGRect(x: 100, y: 200, width: 560, height: 50), withAttributes: bodyAttributes)

        image.unlockFocus()
        return image
        #endif
    }
}
