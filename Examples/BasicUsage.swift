import Foundation
import SwiftIntelligenceCore
import SwiftIntelligenceNLP
import SwiftIntelligenceVision
import SwiftIntelligenceSpeech
import SwiftIntelligencePrivacy

/// SwiftIntelligence Framework - Basic Usage Examples
/// Demonstrates key AI/ML capabilities across all modules
@main
struct SwiftIntelligenceDemo {
    
    static func main() async {
        print("🧠 SwiftIntelligence Framework - Basic Usage Demo")
        print("================================================")
        
        await runNLPDemo()
        await runVisionDemo()
        await runSpeechDemo()
        await runPrivacyDemo()
        
        print("\n✅ All demos completed successfully!")
    }
    
    // MARK: - Natural Language Processing Demo
    
    static func runNLPDemo() async {
        print("\n📝 NLP Module Demo")
        print("-----------------")
        
        do {
            let nlpEngine = NLPEngine.shared
            
            // Text analysis
            let text = "SwiftIntelligence is an amazing AI framework for iOS and macOS!"
            let result = try await nlpEngine.analyzeText(
                text,
                options: NLPAnalysisOptions(
                    enableSentiment: true,
                    enableEntities: true,
                    enableKeywords: true
                )
            )
            
            print("📊 Analysis Results:")
            print("   Sentiment: \(result.sentiment?.label ?? "Unknown") (\(result.sentiment?.confidence ?? 0.0))")
            print("   Language: \(result.language)")
            print("   Keywords: \(result.keywords.prefix(3).map { $0.text }.joined(separator: ", "))")
            
            // Text generation
            let summary = try await nlpEngine.summarizeText(text, maxLength: 50)
            print("   Summary: \(summary.summary)")
            
        } catch {
            print("❌ NLP Error: \(error)")
        }
    }
    
    // MARK: - Computer Vision Demo
    
    static func runVisionDemo() async {
        print("\n👁️ Vision Module Demo")
        print("--------------------")
        
        do {
            let visionEngine = VisionEngine.shared
            
            // Create a sample image (in real usage, load from file)
            #if canImport(UIKit)
            guard let image = createSampleImage() else {
                print("❌ Could not create sample image")
                return
            }
            #else
            print("⚠️ Vision demo requires UIKit (iOS/tvOS)")
            return
            #endif
            
            // Object detection
            let detectionResult = try await visionEngine.detectObjects(
                in: image,
                options: ObjectDetectionOptions(
                    confidenceThreshold: 0.5,
                    enableClassification: true
                )
            )
            
            print("🔍 Detection Results:")
            print("   Objects found: \(detectionResult.detectedObjects.count)")
            for object in detectionResult.detectedObjects.prefix(3) {
                print("   - \(object.classification): \(String(format: "%.1f%%", object.confidence * 100))")
            }
            
            // Text recognition
            let textResult = try await visionEngine.recognizeText(
                in: image,
                options: TextRecognitionOptions.default
            )
            
            if !textResult.recognizedText.isEmpty {
                print("📝 Text Recognition:")
                print("   Text: \(textResult.recognizedText.prefix(50))...")
            }
            
        } catch {
            print("❌ Vision Error: \(error)")
        }
    }
    
    // MARK: - Speech Processing Demo
    
    static func runSpeechDemo() async {
        print("\n🎤 Speech Module Demo")
        print("-------------------")
        
        do {
            let speechEngine = SpeechEngine.shared
            
            // Text-to-Speech
            let textToSpeak = "Hello from SwiftIntelligence!"
            let speechResult = try await speechEngine.synthesizeSpeech(
                from: textToSpeak,
                options: SpeechSynthesisOptions.default
            )
            
            print("🔊 Speech Synthesis:")
            print("   Text: \(speechResult.originalText)")
            print("   Duration: \(String(format: "%.1f", speechResult.duration))s")
            print("   Processing time: \(String(format: "%.3f", speechResult.processingTime))s")
            
            // Get available voices
            let voices = speechEngine.getAvailableVoices(for: "en-US")
            print("   Available voices: \(voices.count)")
            
        } catch {
            print("❌ Speech Error: \(error)")
        }
    }
    
    // MARK: - Privacy & Tokenization Demo
    
    static func runPrivacyDemo() async {
        print("\n🔒 Privacy Module Demo")
        print("--------------------")
        
        do {
            let tokenizer = PrivacyTokenizer()
            
            // Tokenize sensitive data
            let sensitiveEmail = "john.doe@example.com"
            let context = TokenizationContext(
                purpose: .email,
                dataClassification: .sensitive,
                retentionPolicy: .shortTerm
            )
            
            let tokenizedData = try await tokenizer.tokenize(sensitiveEmail, context: context)
            print("🛡️ Privacy Tokenization:")
            print("   Original: \(sensitiveEmail)")
            print("   Tokenized: \(tokenizedData.tokens.first ?? "N/A")")
            
            // Detokenize
            let detokenized = try await tokenizer.detokenize(tokenizedData)
            print("   Detokenized: \(detokenized)")
            print("   Match: \(sensitiveEmail == detokenized ? "✅" : "❌")")
            
            // Format-preserving tokenization
            let creditCard = "4532-1234-5678-9012"
            let tokenizedCard = try await tokenizer.formatPreservingTokenize(
                creditCard,
                context: TokenizationContext(
                    purpose: .creditCard,
                    dataClassification: .highlyConfidential,
                    retentionPolicy: .shortTerm
                )
            )
            print("   Credit Card: \(creditCard) → \(tokenizedCard)")
            
        } catch {
            print("❌ Privacy Error: \(error)")
        }
    }
    
    // MARK: - Helper Methods
    
    #if canImport(UIKit)
    static func createSampleImage() -> UIImage? {
        // Create a simple colored rectangle as sample
        let size = CGSize(width: 200, height: 100)
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.blue.cgColor)
        context?.fill(CGRect(origin: .zero, size: size))
        
        // Add some text
        let text = "SAMPLE"
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 24)
        ]
        
        let textSize = text.size(withAttributes: attributes)
        let textRect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        text.draw(in: textRect, withAttributes: attributes)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    #endif
}

// MARK: - Extensions for Demo

extension NLPAnalysisOptions {
    static let demo = NLPAnalysisOptions(
        enableSentiment: true,
        enableEntities: true,
        enableKeywords: true,
        enableLanguageDetection: true,
        enableSummary: true
    )
}

extension ObjectDetectionOptions {
    static let demo = ObjectDetectionOptions(
        confidenceThreshold: 0.6,
        enableClassification: true,
        maxObjects: 10
    )
}

extension TextRecognitionOptions {
    static let demo = TextRecognitionOptions(
        enablePartialResults: false,
        requireOnDeviceRecognition: true,
        addPunctuation: true,
        detectLanguage: true
    )
}