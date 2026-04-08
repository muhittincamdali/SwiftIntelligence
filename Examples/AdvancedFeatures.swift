import Foundation
import SwiftIntelligenceCore
import SwiftIntelligenceML
import SwiftIntelligenceNLP
import SwiftIntelligenceVision
import SwiftIntelligenceSpeech
import SwiftIntelligencePrivacy

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Advanced examples aligned with the current modular package graph.
@MainActor
final class AdvancedFeaturesDemo {
    func runPrivacyAwareClassification() async throws {
        SwiftIntelligenceCore.shared.configure(with: .production)

        let tokenizer = PrivacyTokenizer()
        let context = TokenizationContext(
            purpose: .email,
            sensitivity: .high,
            retentionPolicy: .temporary
        )

        let sample = "owner@example.com prepared the quarterly review"
        let maskedEmail = try await tokenizer.formatPreservingTokenize("owner@example.com", context: context)
        let maskedText = sample.replacingOccurrences(of: "owner@example.com", with: maskedEmail)

        let engine = try await SwiftIntelligenceML()
        defer { Task { try? await engine.shutdown() } }

        let training = MLTrainingData(
            inputs: [
                MLInput(features: [0.0, 0.0]),
                MLInput(features: [1.0, 1.0])
            ],
            expectedOutputs: [
                MLOutput(prediction: [0], classificationResult: "internal", confidence: 1.0),
                MLOutput(prediction: [0], classificationResult: "external", confidence: 1.0)
            ]
        )

        _ = try await engine.train(modelID: "classification", with: training)
        let prediction = try await engine.predict(
            modelID: "classification",
            input: MLInput(features: [0.1, 0.1], metadata: ["sample": maskedText])
        )

        print("Masked text: \(maskedText)")
        print("Predicted class: \(prediction.classificationResult ?? "unknown")")
    }

    @MainActor
    func runDocumentPipeline(image: PlatformImage) async throws {
        SwiftIntelligenceCore.shared.configure(with: .production)

        let vision = VisionEngine.shared
        try await vision.initialize()
        defer { Task { await vision.shutdown() } }

        let document = try await vision.analyzeDocument(image, options: .default)
        let recognizedText = document.documentText

        let nlp = NLPEngine.shared
        let summary = try await nlp.summarizeText(text: recognizedText, maxSentences: 2)

        print("Paragraphs: \(document.layout.paragraphs.count)")
        print("Summary: \(summary.summary)")
    }

    @MainActor
    func runBatchVisionWorkflow(images: [PlatformImage]) async throws {
        let vision = VisionEngine.shared
        try await vision.initialize()
        defer { Task { await vision.shutdown() } }

        let classifications = try await vision.batchClassifyImages(images, options: .default)
        let operations = images.map { VisionOperation.recognizeText($0, .default) }
        let results = try await vision.batchProcess(operations)

        print("Classifications: \(classifications.count)")
        print("Batch operations: \(results.count)")
    }

    func runVoiceCatalogInspection() {
        let englishVoices = SpeechEngine.availableVoices(for: "en-US")
        let turkishVoices = SpeechEngine.availableVoices(for: "tr-TR")

        print("English voices: \(englishVoices.count)")
        print("Turkish voices: \(turkishVoices.count)")
    }
}
