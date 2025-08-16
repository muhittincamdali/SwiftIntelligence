import Foundation
import SwiftIntelligenceCore
import SwiftIntelligenceNLP
import SwiftIntelligenceVision
import SwiftIntelligenceSpeech
import SwiftIntelligencePrivacy
import SwiftIntelligenceReasoning
import SwiftIntelligenceMachineLearning

/// SwiftIntelligence Framework - Advanced Features Demo
/// Showcases complex AI/ML workflows and multi-modal processing
class AdvancedFeaturesDemo {
    
    // MARK: - Properties
    
    private let logger = Logger(subsystem: "SwiftIntelligence", category: "AdvancedDemo")
    private let performanceMonitor = PerformanceMonitor()
    
    // MARK: - Advanced Workflows
    
    /// Multi-modal content analysis combining vision, NLP, and speech
    func runMultiModalAnalysis() async throws {
        logger.info("🔀 Starting Multi-Modal Analysis")
        
        // 1. Process image with advanced vision
        #if canImport(UIKit)
        guard let image = createComplexSampleImage() else {
            throw DemoError.imageCreationFailed
        }
        
        let visionEngine = VisionEngine.shared
        
        // Advanced object detection with classification
        let detectionResult = try await visionEngine.detectObjects(
            in: image,
            options: ObjectDetectionOptions(
                confidenceThreshold: 0.7,
                enableClassification: true,
                maxObjects: 20
            )
        )
        
        // Text recognition from image
        let textResult = try await visionEngine.recognizeText(
            in: image,
            options: TextRecognitionOptions(
                enablePartialResults: false,
                requireOnDeviceRecognition: true,
                addPunctuation: true,
                detectLanguage: true
            )
        )
        
        logger.info("Vision Results: \(detectionResult.detectedObjects.count) objects, text: '\(textResult.recognizedText)'")
        
        // 2. Analyze extracted text with NLP
        if !textResult.recognizedText.isEmpty {
            let nlpEngine = NLPEngine.shared
            
            let nlpResult = try await nlpEngine.analyzeText(
                textResult.recognizedText,
                options: NLPAnalysisOptions(
                    enableSentiment: true,
                    enableEntities: true,
                    enableKeywords: true,
                    enableLanguageDetection: true,
                    enableSummary: true
                )
            )
            
            // 3. Generate speech summary
            let speechEngine = SpeechEngine.shared
            let summaryText = "Image contains \(detectionResult.detectedObjects.count) objects. " +
                            "Text analysis shows \(nlpResult.sentiment?.label ?? "neutral") sentiment. " +
                            "Key entities: \(nlpResult.entities.prefix(3).map { $0.text }.joined(separator: ", "))"
            
            let speechResult = try await speechEngine.synthesizeSpeech(
                from: summaryText,
                options: SpeechSynthesisOptions(
                    speed: 0.8,
                    pitch: 1.0,
                    volume: 0.9,
                    enableSSML: false
                )
            )
            
            logger.info("Multi-modal analysis complete: \(speechResult.duration)s speech generated")
        }
        #endif
    }
    
    /// Advanced privacy-preserving ML pipeline
    func runPrivacyPreservingMLPipeline() async throws {
        logger.info("🔒 Starting Privacy-Preserving ML Pipeline")
        
        let tokenizer = PrivacyTokenizer()
        let mlEngine = MLEngine.shared
        
        // 1. Tokenize sensitive training data
        let sensitiveData = [
            "john.doe@company.com worked on project Alpha",
            "jane.smith@corp.com analyzed data for project Beta",
            "mike.wilson@startup.io developed features for project Gamma"
        ]
        
        var tokenizedTrainingData: [String] = []
        
        for text in sensitiveData {
            // Extract and tokenize email addresses
            let emailPattern = #"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"#
            let regex = try NSRegularExpression(pattern: emailPattern)
            let range = NSRange(location: 0, length: text.utf16.count)
            
            var processedText = text
            let matches = regex.matches(in: text, range: range)
            
            for match in matches.reversed() {
                if let emailRange = Range(match.range, in: text) {
                    let email = String(text[emailRange])
                    
                    let tokenizedEmail = try await tokenizer.formatPreservingTokenize(
                        email,
                        context: TokenizationContext(
                            purpose: .email,
                            dataClassification: .sensitive,
                            retentionPolicy: .mediumTerm
                        )
                    )
                    
                    processedText = processedText.replacingCharacters(in: emailRange, with: tokenizedEmail)
                }
            }
            
            tokenizedTrainingData.append(processedText)
        }
        
        // 2. Train model on tokenized data
        let modelResult = try await mlEngine.trainTextClassificationModel(
            trainingData: tokenizedTrainingData,
            labels: ["project-alpha", "project-beta", "project-gamma"],
            configuration: MLTrainingConfiguration(
                epochs: 10,
                batchSize: 32,
                learningRate: 0.001,
                enablePrivacyPreserving: true
            )
        )
        
        logger.info("Privacy-preserving model trained: \(modelResult.accuracy) accuracy")
        
        // 3. Demonstrate inference with privacy preservation
        let testInput = "user@example.com is working on a new initiative"
        let tokenizedInput = try await tokenizer.formatPreservingTokenize(
            "user@example.com",
            context: TokenizationContext(
                purpose: .email,
                dataClassification: .sensitive,
                retentionPolicy: .shortTerm
            )
        )
        
        let finalInput = testInput.replacingOccurrences(of: "user@example.com", with: tokenizedInput)
        
        let prediction = try await mlEngine.classifyText(
            finalInput,
            modelId: modelResult.modelId
        )
        
        logger.info("Privacy-preserving prediction: \(prediction.predictedClass) (\(prediction.confidence))")
    }
    
    /// Advanced reasoning and decision making
    func runAdvancedReasoning() async throws {
        logger.info("🧠 Starting Advanced Reasoning Demo")
        
        let reasoningEngine = ReasoningEngine.shared
        
        // 1. Create knowledge base
        let facts = [
            "All birds can fly",
            "Penguins are birds",
            "Ostriches are birds",
            "Penguins cannot fly",
            "Ostriches cannot fly"
        ]
        
        let knowledgeBase = try await reasoningEngine.createKnowledgeBase(from: facts)
        
        // 2. Complex reasoning query
        let query = "If penguins are birds and all birds can fly, why can't penguins fly?"
        
        let reasoningResult = try await reasoningEngine.performReasoning(
            query: query,
            knowledgeBase: knowledgeBase,
            options: ReasoningOptions(
                enableContradictionDetection: true,
                enableExplanation: true,
                maxInferenceSteps: 10
            )
        )
        
        logger.info("Reasoning result: \(reasoningResult.conclusion)")
        logger.info("Confidence: \(reasoningResult.confidence)")
        
        if !reasoningResult.contradictions.isEmpty {
            logger.info("Contradictions found: \(reasoningResult.contradictions.count)")
        }
        
        // 3. Decision tree analysis
        let decisionResult = try await reasoningEngine.analyzeDecision(
            scenario: "Choose between three ML models for text classification",
            criteria: [
                "Accuracy > 90%",
                "Inference time < 100ms",
                "Model size < 50MB",
                "Privacy compliance required"
            ],
            options: [
                "BERT-large": ["accuracy": 0.95, "speed": 200, "size": 110, "privacy": 0.6],
                "DistilBERT": ["accuracy": 0.92, "speed": 50, "size": 25, "privacy": 0.8],
                "Custom-CNN": ["accuracy": 0.88, "speed": 20, "size": 15, "privacy": 0.9]
            ]
        )
        
        logger.info("Decision analysis: Best option is \(decisionResult.recommendedOption)")
    }
    
    /// Real-time performance monitoring and optimization
    func runPerformanceOptimization() async throws {
        logger.info("⚡ Starting Performance Optimization Demo")
        
        // 1. Start performance monitoring
        let monitor = PerformanceMonitor()
        let session = await monitor.startMonitoringSession(
            name: "Advanced Demo",
            configuration: PerformanceConfiguration(
                enableCPUMonitoring: true,
                enableMemoryMonitoring: true,
                enableNetworkMonitoring: true,
                samplingInterval: 0.1
            )
        )
        
        // 2. Run CPU-intensive NLP task
        let nlpEngine = NLPEngine.shared
        let startTime = Date()
        
        let largeDocs = [
            String(repeating: "The quick brown fox jumps over the lazy dog. ", count: 1000),
            String(repeating: "SwiftIntelligence provides advanced AI capabilities. ", count: 1000),
            String(repeating: "Machine learning enables intelligent data processing. ", count: 1000)
        ]
        
        var results: [NLPAnalysisResult] = []
        
        for doc in largeDocs {
            let result = try await nlpEngine.analyzeText(
                doc,
                options: NLPAnalysisOptions.demo
            )
            results.append(result)
        }
        
        let processingTime = Date().timeIntervalSince(startTime)
        
        // 3. Get performance metrics
        let metrics = await monitor.getMetrics(for: session)
        await monitor.stopMonitoringSession(session)
        
        logger.info("Performance Results:")
        logger.info("  Processing time: \(String(format: "%.2f", processingTime))s")
        logger.info("  Documents processed: \(results.count)")
        logger.info("  Avg CPU usage: \(String(format: "%.1f", metrics.averageCPUUsage))%")
        logger.info("  Peak memory: \(String(format: "%.1f", metrics.peakMemoryUsage / 1024 / 1024))MB")
        
        // 4. Optimization recommendations
        if metrics.averageCPUUsage > 80 {
            logger.warning("High CPU usage detected - consider batch processing")
        }
        
        if metrics.peakMemoryUsage > 500 * 1024 * 1024 {
            logger.warning("High memory usage - consider streaming processing")
        }
    }
    
    // MARK: - Helper Methods
    
    #if canImport(UIKit)
    private func createComplexSampleImage() -> UIImage? {
        let size = CGSize(width: 400, height: 300)
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Create gradient background
        let colors = [UIColor.blue.cgColor, UIColor.purple.cgColor]
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: nil)!
        context.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: size.width, y: size.height), options: [])
        
        // Add shapes
        context.setFillColor(UIColor.white.cgColor)
        context.fillEllipse(in: CGRect(x: 50, y: 50, width: 100, height: 100))
        
        context.setFillColor(UIColor.yellow.cgColor)
        context.fill(CGRect(x: 200, y: 100, width: 80, height: 80))
        
        // Add text
        let text = "SwiftIntelligence\nAdvanced AI Framework\nfor Apple Platforms"
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 16),
            .paragraphStyle: paragraphStyle
        ]
        
        let textRect = CGRect(x: 20, y: 200, width: size.width - 40, height: 80)
        text.draw(in: textRect, withAttributes: attributes)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    #endif
}

// MARK: - Supporting Types

enum DemoError: LocalizedError {
    case imageCreationFailed
    case processingFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .imageCreationFailed:
            return "Failed to create sample image"
        case .processingFailed(let reason):
            return "Processing failed: \(reason)"
        }
    }
}

// MARK: - Demo Extensions

extension NLPAnalysisOptions {
    static let advanced = NLPAnalysisOptions(
        enableSentiment: true,
        enableEntities: true,
        enableKeywords: true,
        enableLanguageDetection: true,
        enableSummary: true,
        enableTopicModeling: true,
        maxKeywords: 10
    )
}

extension MLTrainingConfiguration {
    static let privacyPreserving = MLTrainingConfiguration(
        epochs: 20,
        batchSize: 16,
        learningRate: 0.0001,
        enablePrivacyPreserving: true,
        enableDifferentialPrivacy: true,
        privacyBudget: 1.0
    )
}

extension ReasoningOptions {
    static let comprehensive = ReasoningOptions(
        enableContradictionDetection: true,
        enableExplanation: true,
        enableUncertaintyQuantification: true,
        maxInferenceSteps: 50,
        confidenceThreshold: 0.8
    )
}

// MARK: - Usage Example

/*
// Usage in your app:

@main
struct AdvancedDemoApp {
    static func main() async {
        let demo = AdvancedFeaturesDemo()
        
        do {
            await demo.runMultiModalAnalysis()
            await demo.runPrivacyPreservingMLPipeline()
            await demo.runAdvancedReasoning()
            await demo.runPerformanceOptimization()
            
            print("✅ All advanced demos completed successfully!")
            
        } catch {
            print("❌ Demo failed: \(error)")
        }
    }
}
*/