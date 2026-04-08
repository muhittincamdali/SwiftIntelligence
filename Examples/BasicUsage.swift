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

/// Basic modular examples for the active SwiftIntelligence package graph.
@main
struct SwiftIntelligenceDemo {
    @MainActor
    static func main() async {
        SwiftIntelligenceCore.shared.configure(with: .production)

        await runNLPDemo()
        await runVisionDemo()
        await runSpeechDemo()
        await runPrivacyDemo()
        await runMLDemo()

        SwiftIntelligenceCore.shared.cleanup()
    }

    static func runNLPDemo() async {
        print("\nNLP Demo")

        do {
            let text = "Apple builds amazing products in Cupertino."
            let result = try await NLPEngine.shared.analyze(
                text: text,
                options: NLPOptions(
                    includeSentiment: true,
                    includeEntities: true,
                    includeKeywords: true,
                    includeLanguageDetection: true
                )
            )

            let sentiment = result.analysisResults["sentiment"] as? SentimentResult
            let entities = result.analysisResults["entities"] as? [NamedEntity]
            let keywords = result.analysisResults["keywords"] as? [Keyword]

            print("Language: \(result.detectedLanguage.rawValue)")
            print("Sentiment: \(sentiment?.sentiment.rawValue ?? "unknown")")
            print("Entities: \(entities?.map(\.text) ?? [])")
            print("Keywords: \(keywords?.prefix(3).map(\.word) ?? [])")
        } catch {
            print("NLP error: \(error)")
        }
    }

    @MainActor
    static func runVisionDemo() async {
        print("\nVision Demo")

        guard let image = makeSampleImage() else {
            print("Vision demo skipped: sample image could not be created")
            return
        }

        let engine = VisionEngine.shared

        do {
            try await engine.initialize()
            defer { Task { await engine.shutdown() } }

            let classification = try await engine.classifyImage(image, options: .default)
            print("Top label: \(classification.classifications.first?.label ?? "unknown")")

            let ocr = try await engine.recognizeText(in: image, options: .default)
            print("Recognized text: \(ocr.recognizedText)")
        } catch {
            print("Vision error: \(error)")
        }
    }

    @MainActor
    static func runSpeechDemo() async {
        print("\nSpeech Demo")

        let voices = SpeechEngine.availableVoices(for: "en-US")
        print("Available voices: \(voices.prefix(3).map(\.name))")

        do {
            let result = try await SpeechEngine.shared.synthesizeSpeech(
                from: "Hello from SwiftIntelligence.",
                options: .default
            )

            print("Synthesized duration: \(result.duration)")
        } catch {
            print("Speech synthesis error: \(error)")
        }
    }

    static func runPrivacyDemo() async {
        print("\nPrivacy Demo")

        let tokenizer = PrivacyTokenizer()
        let context = TokenizationContext(
            purpose: .email,
            sensitivity: .high,
            retentionPolicy: .temporary
        )

        do {
            let tokenized = try await tokenizer.tokenize("john.doe@example.com", context: context)
            let restored = try await tokenizer.detokenize(tokenized)

            print("Token: \(tokenized.tokens.first ?? "n/a")")
            print("Detokenized: \(restored)")

            let maskedCard = try await tokenizer.formatPreservingTokenize(
                "4532-1234-5678-9012",
                context: TokenizationContext(
                    purpose: .creditCard,
                    sensitivity: .critical,
                    retentionPolicy: .temporary
                )
            )

            print("Format-preserving token: \(maskedCard)")
        } catch {
            print("Privacy error: \(error)")
        }
    }

    static func runMLDemo() async {
        print("\nML Demo")

        do {
            let engine = try await SwiftIntelligenceML()
            defer { Task { try? await engine.shutdown() } }

            let training = MLTrainingData(
                inputs: [
                    MLInput(features: [0.0, 0.0]),
                    MLInput(features: [0.1, 0.1]),
                    MLInput(features: [1.0, 1.0]),
                    MLInput(features: [1.1, 1.1])
                ],
                expectedOutputs: [
                    MLOutput(prediction: [0], classificationResult: "class_0", confidence: 1.0),
                    MLOutput(prediction: [0], classificationResult: "class_0", confidence: 1.0),
                    MLOutput(prediction: [0], classificationResult: "class_1", confidence: 1.0),
                    MLOutput(prediction: [0], classificationResult: "class_1", confidence: 1.0)
                ]
            )

            _ = try await engine.train(modelID: "classification", with: training)
            let prediction = try await engine.predict(
                modelID: "classification",
                input: MLInput(features: [0.05, 0.05])
            )

            print("Prediction: \(prediction.classificationResult ?? "unknown")")
        } catch {
            print("ML error: \(error)")
        }
    }

    @MainActor
    static func makeSampleImage() -> PlatformImage? {
        #if canImport(UIKit)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 160, height: 80))
        return renderer.image { context in
            UIColor.systemBlue.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 160, height: 80))

            let text = "SAMPLE"
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.white,
                .font: UIFont.boldSystemFont(ofSize: 24)
            ]
            text.draw(at: CGPoint(x: 24, y: 24), withAttributes: attributes)
        }
        #elseif canImport(AppKit)
        let size = NSSize(width: 160, height: 80)
        let image = NSImage(size: size)
        image.lockFocus()
        NSColor.systemBlue.setFill()
        NSBezierPath(rect: NSRect(x: 0, y: 0, width: 160, height: 80)).fill()
        let text = NSString(string: "SAMPLE")
        text.draw(
            at: NSPoint(x: 24, y: 24),
            withAttributes: [
                .foregroundColor: NSColor.white,
                .font: NSFont.boldSystemFont(ofSize: 24)
            ]
        )
        image.unlockFocus()
        return image
        #endif
    }
}
