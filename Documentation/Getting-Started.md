# Getting Started with SwiftIntelligence

This guide will help you get up and running with SwiftIntelligence in your iOS, macOS, or visionOS application.

## 📋 Prerequisites

- **Xcode 15.0+**
- **iOS 17.0+**, **macOS 14.0+**, or **visionOS 1.0+**
- **Swift 5.9+**
- **API Keys** for external providers (OpenAI, Anthropic, Google AI) - optional

## 📦 Installation

### Swift Package Manager

Add SwiftIntelligence to your project using Xcode's Swift Package Manager:

1. Open your project in Xcode
2. Go to **File → Add Package Dependencies**
3. Enter the repository URL: `https://github.com/your-org/SwiftIntelligence.git`
4. Choose the version constraint (latest is recommended)
5. Click **Add Package**

Alternatively, add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-org/SwiftIntelligence.git", from: "1.0.0")
]
```

### Manual Installation

1. Clone the repository
2. Drag the `SwiftIntelligence.xcodeproj` into your project
3. Add SwiftIntelligence to your target dependencies
4. Import the framework in your Swift files

## 🚀 Quick Start

### 1. Import the Framework

```swift
import SwiftIntelligence
```

### 2. Initialize the Intelligence Engine

```swift
import SwiftUI
import SwiftIntelligence

@main
struct MyApp: App {
    @StateObject private var aiEngine = IntelligenceEngine()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    Task {
                        await initializeAI()
                    }
                }
        }
    }
    
    private func initializeAI() async {
        do {
            try await aiEngine.initialize()
            print("SwiftIntelligence initialized successfully!")
        } catch {
            print("Failed to initialize SwiftIntelligence: \(error)")
        }
    }
}
```

### 3. Basic Usage Examples

#### Computer Vision

```swift
import SwiftIntelligence

class VisionExample {
    private var aiEngine: IntelligenceEngine!
    
    func detectObjects(in image: UIImage) async throws {
        // Get the vision engine
        let visionEngine = try await aiEngine.getVisionEngine()
        
        // Convert UIImage to CIImage
        guard let ciImage = CIImage(image: image) else {
            throw VisionError.invalidImage
        }
        
        // Create object detection request
        let request = VisionRequest.objectDetection(
            threshold: 0.5,
            classes: ["person", "car", "dog", "cat"]
        )
        
        // Process the image
        let result = try await visionEngine.processImage(ciImage, with: request)
        
        // Handle the results
        if case .objectDetection(let detections) = result {
            for detection in detections {
                print("Found \(detection.label) with confidence \(detection.confidence)")
            }
        }
    }
}
```

#### Natural Language Processing

```swift
import SwiftIntelligence

class NLPExample {
    private var aiEngine: IntelligenceEngine!
    
    func analyzeSentiment(text: String) async throws {
        // Get the NLP engine
        let nlpEngine = try await aiEngine.getNaturalLanguageEngine()
        
        // Create sentiment analysis request
        let request = NLPRequest.sentimentAnalysis(
            text: text,
            language: .english
        )
        
        // Process the text
        let result = try await nlpEngine.processText(request)
        
        // Handle the results
        if case .sentimentAnalysis(let sentiments) = result {
            for sentiment in sentiments {
                print("Sentiment: \(sentiment.label) (\(sentiment.confidence))")
            }
        }
    }
    
    func detectLanguage(text: String) async throws {
        let nlpEngine = try await aiEngine.getNaturalLanguageEngine()
        let language = try await nlpEngine.detectLanguage(text)
        print("Detected language: \(language)")
    }
}
```

#### Speech Recognition

```swift
import SwiftIntelligence
import AVFoundation

class SpeechExample {
    private var aiEngine: IntelligenceEngine!
    
    func recognizeSpeech(audioData: Data) async throws {
        // Get the speech engine
        let speechEngine = try await aiEngine.getSpeechEngine()
        
        // Create recognition request
        let request = SpeechRequest.recognition(
            language: .english,
            enablePunctuation: true,
            enableNoiseReduction: true
        )
        
        // Process the audio
        let result = try await speechEngine.processAudio(audioData, with: request)
        
        // Handle the results
        if case .recognition(let recognition) = result {
            print("Transcription: \(recognition.transcription)")
            print("Confidence: \(recognition.confidence)")
        }
    }
    
    func synthesizeSpeech(text: String) async throws -> Data {
        let speechEngine = try await aiEngine.getSpeechEngine()
        
        let request = SpeechRequest.synthesis(
            text: text,
            voice: .natural,
            language: .english,
            rate: 1.0
        )
        
        let result = try await speechEngine.synthesizeSpeech(request)
        return result.audioData
    }
}
```

#### Large Language Models

```swift
import SwiftIntelligence

class LLMExample {
    private var aiEngine: IntelligenceEngine!
    
    func setupProviders() async throws {
        let llmEngine = try await aiEngine.getLLMEngine()
        
        // Add OpenAI provider (requires API key)
        let openAIProvider = OpenAIProvider(apiKey: "your-openai-api-key")
        try await llmEngine.addProvider(openAIProvider)
        
        // Add Anthropic provider (requires API key)
        let anthropicProvider = AnthropicProvider(apiKey: "your-anthropic-api-key")
        try await llmEngine.addProvider(anthropicProvider)
        
        // Add local provider (no API key required)
        let localProvider = LocalLLMProvider()
        try await llmEngine.addProvider(localProvider)
    }
    
    func generateResponse(prompt: String) async throws {
        let llmEngine = try await aiEngine.getLLMEngine()
        
        let request = LLMRequest(
            messages: [
                LLMMessage(role: .system, content: "You are a helpful assistant."),
                LLMMessage(role: .user, content: prompt)
            ],
            model: .gpt4,
            maxTokens: 500,
            temperature: 0.7
        )
        
        let response = try await llmEngine.generateResponse(request)
        print("AI Response: \(response.content)")
    }
    
    func streamResponse(prompt: String) async throws {
        let llmEngine = try await aiEngine.getLLMEngine()
        
        let request = LLMRequest(
            messages: [LLMMessage(role: .user, content: prompt)],
            model: .gpt4,
            maxTokens: 500,
            temperature: 0.7
        )
        
        let stream = llmEngine.streamResponse(request)
        
        for try await token in stream {
            print(token.content, terminator: "")
        }
        print() // New line at the end
    }
}
```

## 🔧 Configuration

### Basic Configuration

```swift
let config = IntelligenceConfiguration(
    // Enable specific engines
    enableVision: true,
    enableNLP: true,
    enableSpeech: true,
    enableLLM: true,
    enableImageGeneration: true,
    enableVisionOS: true,
    
    // Privacy settings
    privacyLevel: .standard,
    enableDataAnonymization: true,
    
    // Performance settings
    performanceProfile: .balanced,
    enableCaching: true,
    maxCacheSize: .megabytes(500)
)

let aiEngine = IntelligenceEngine(configuration: config)
```

### Advanced Configuration

```swift
let advancedConfig = IntelligenceConfiguration(
    enabledEngines: [.vision, .nlp, .speech, .llm],
    privacyLevel: .high,
    performanceProfile: .optimized,
    cachingPolicy: CachingPolicy(
        enableResultCaching: true,
        enableModelCaching: true,
        maxCacheSize: .gigabytes(1),
        ttl: .minutes(30)
    ),
    loggingLevel: .info,
    enableAnalytics: false,
    networkConfiguration: NetworkConfiguration(
        timeout: 30.0,
        retryPolicy: .exponentialBackoff,
        enableCompression: true
    )
)
```

## 🥽 visionOS Integration

### Basic visionOS Setup

```swift
import SwiftIntelligence
import RealityKit

@main
struct VisionOSApp: App {
    @StateObject private var aiEngine = IntelligenceEngine()
    
    var body: some Scene {
        WindowGroup {
            VisionContentView()
                .onAppear {
                    Task {
                        await initializeVisionOS()
                    }
                }
        }
    }
    
    private func initializeVisionOS() async {
        do {
            try await aiEngine.initialize()
            
            // Initialize visionOS engine
            let visionOSEngine = try await aiEngine.getVisionOSEngine()
            try await visionOSEngine.initialize(with: .development)
            
            print("visionOS AI integration ready!")
        } catch {
            print("Failed to initialize visionOS: \(error)")
        }
    }
}
```

### Spatial Computing Example

```swift
class SpatialComputingExample {
    private var aiEngine: IntelligenceEngine!
    
    func setupSpatialComputing() async throws {
        let visionOSEngine = try await aiEngine.getVisionOSEngine()
        let spatialManager = try await visionOSEngine.getSpatialComputingManager()
        
        // Create spatial anchor
        let anchor = try await spatialManager.createAnchor(
            at: SIMD3<Float>(0, 0, -1),
            name: "ContentAnchor"
        )
        
        print("Created spatial anchor: \(anchor.name)")
    }
    
    func openImmersiveSpace() async throws {
        let visionOSEngine = try await aiEngine.getVisionOSEngine()
        let spaceManager = try await visionOSEngine.getImmersiveSpaceManager()
        
        try await spaceManager.openSpace(.main, style: .progressive)
        print("Immersive space opened")
    }
}
```

## 🔒 Privacy Features

### Data Protection

```swift
class PrivacyExample {
    private var aiEngine: IntelligenceEngine!
    
    func protectSensitiveData() async throws {
        let privacyEngine = try await aiEngine.getPrivacyEngine()
        
        let sensitiveText = "My credit card number is 1234-5678-9012-3456"
        
        // Automatic protection
        let protectedText = try await privacyEngine.protectSensitiveText(
            sensitiveText,
            classification: .confidential
        )
        
        print("Protected text: \(protectedText)")
        // Output: "My credit card number is [REDACTED]"
    }
    
    func anonymizeUserData() async throws {
        let privacyEngine = try await aiEngine.getPrivacyEngine()
        
        let userData = UserData(
            name: "John Doe",
            email: "john.doe@example.com",
            phoneNumber: "+1-555-123-4567"
        )
        
        let anonymizedData = try await privacyEngine.anonymizeData(
            userData,
            level: .standard
        )
        
        print("Anonymized data: \(anonymizedData)")
    }
}
```

## 📱 SwiftUI Integration

### Reactive AI Components

```swift
import SwiftUI
import SwiftIntelligence

struct AIImageAnalyzer: View {
    @StateObject private var aiEngine = IntelligenceEngine()
    @State private var selectedImage: UIImage?
    @State private var analysisResult: String = ""
    @State private var isAnalyzing = false
    
    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 300)
            }
            
            Button("Select Image") {
                // Image picker implementation
            }
            
            if !analysisResult.isEmpty {
                Text(analysisResult)
                    .padding()
            }
            
            if isAnalyzing {
                ProgressView("Analyzing...")
            }
        }
        .onAppear {
            Task {
                try? await aiEngine.initialize()
            }
        }
        .onChange(of: selectedImage) { image in
            if let image = image {
                analyzeImage(image)
            }
        }
    }
    
    private func analyzeImage(_ image: UIImage) {
        Task {
            isAnalyzing = true
            defer { isAnalyzing = false }
            
            do {
                let visionEngine = try await aiEngine.getVisionEngine()
                let ciImage = CIImage(image: image)!
                
                let request = VisionRequest.imageClassification(
                    maxResults: 3,
                    threshold: 0.3
                )
                
                let result = try await visionEngine.processImage(ciImage, with: request)
                
                if case .imageClassification(let classifications) = result {
                    let descriptions = classifications.map { 
                        "\($0.label) (\(Int($0.confidence * 100))%)" 
                    }
                    analysisResult = descriptions.joined(separator: "\n")
                }
            } catch {
                analysisResult = "Analysis failed: \(error.localizedDescription)"
            }
        }
    }
}
```

### Voice-Enabled Chat

```swift
struct VoiceChat: View {
    @StateObject private var aiEngine = IntelligenceEngine()
    @State private var messages: [ChatMessage] = []
    @State private var isListening = false
    @State private var isProcessing = false
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(messages) { message in
                        ChatBubble(message: message)
                    }
                }
            }
            
            HStack {
                Button(action: toggleListening) {
                    Image(systemName: isListening ? "mic.fill" : "mic")
                        .foregroundColor(isListening ? .red : .blue)
                        .font(.title2)
                }
                .disabled(isProcessing)
                
                if isProcessing {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            .padding()
        }
        .onAppear {
            Task {
                try? await aiEngine.initialize()
            }
        }
    }
    
    private func toggleListening() {
        if isListening {
            stopListening()
        } else {
            startListening()
        }
    }
    
    private func startListening() {
        isListening = true
        // Voice recording implementation
    }
    
    private func stopListening() {
        isListening = false
        isProcessing = true
        
        Task {
            // Process voice input and generate response
            defer { isProcessing = false }
            
            // Implementation here
        }
    }
}
```

## 🧪 Testing

### Unit Testing

```swift
import XCTest
@testable import SwiftIntelligence

class SwiftIntelligenceTests: XCTestCase {
    var aiEngine: IntelligenceEngine!
    
    override func setUp() async throws {
        aiEngine = IntelligenceEngine(configuration: .testing)
        try await aiEngine.initialize()
    }
    
    func testVisionEngine() async throws {
        let visionEngine = try await aiEngine.getVisionEngine()
        let testImage = createTestImage()
        
        let request = VisionRequest.imageClassification(
            maxResults: 1,
            threshold: 0.1
        )
        
        let result = try await visionEngine.processImage(testImage, with: request)
        
        XCTAssertNotNil(result)
        if case .imageClassification(let classifications) = result {
            XCTAssertFalse(classifications.isEmpty)
        } else {
            XCTFail("Expected image classification result")
        }
    }
    
    func testNLPEngine() async throws {
        let nlpEngine = try await aiEngine.getNaturalLanguageEngine()
        
        let request = NLPRequest.sentimentAnalysis(
            text: "I love this framework!",
            language: .english
        )
        
        let result = try await nlpEngine.processText(request)
        
        XCTAssertNotNil(result)
        if case .sentimentAnalysis(let sentiments) = result {
            XCTAssertFalse(sentiments.isEmpty)
            XCTAssertEqual(sentiments.first?.label, "positive")
        }
    }
}

extension IntelligenceConfiguration {
    static let testing = IntelligenceConfiguration(
        enabledEngines: .all,
        privacyLevel: .standard,
        performanceProfile: .balanced,
        cachingPolicy: .disabled,
        loggingLevel: .debug
    )
}
```

## 🚨 Error Handling

### Comprehensive Error Handling

```swift
class ErrorHandlingExample {
    private var aiEngine: IntelligenceEngine!
    
    func handleVisionErrors() async {
        do {
            let visionEngine = try await aiEngine.getVisionEngine()
            let result = try await visionEngine.processImage(someImage, with: someRequest)
            // Handle success
        } catch VisionError.invalidImage {
            print("The provided image is invalid")
        } catch VisionError.modelNotAvailable(let modelName) {
            print("Model \(modelName) is not available")
        } catch VisionError.processingFailed(let reason) {
            print("Processing failed: \(reason)")
        } catch IntelligenceError.engineNotInitialized {
            print("AI engine not initialized")
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    
    func handleLLMErrors() async {
        do {
            let llmEngine = try await aiEngine.getLLMEngine()
            let response = try await llmEngine.generateResponse(someRequest)
            // Handle success
        } catch LLMError.noProvidersAvailable {
            print("No LLM providers are configured")
        } catch LLMError.rateLimitExceeded(let retryAfter) {
            print("Rate limit exceeded, retry after \(retryAfter) seconds")
        } catch LLMError.invalidAPIKey {
            print("Invalid API key provided")
        } catch LLMError.contentFiltered {
            print("Content was filtered by the provider")
        } catch {
            print("LLM error: \(error)")
        }
    }
}
```

## 📈 Performance Tips

### Optimization Best Practices

1. **Initialize Once**: Create a single `IntelligenceEngine` instance and reuse it
2. **Enable Caching**: Use result caching for repeated operations
3. **Preload Models**: Initialize engines during app startup
4. **Monitor Memory**: Use appropriate cache sizes for your app
5. **Handle Background**: Pause AI operations when app goes to background

```swift
class PerformanceOptimizedAI: ObservableObject {
    private let aiEngine: IntelligenceEngine
    private let backgroundQueue = DispatchQueue(label: "ai.processing", qos: .userInitiated)
    
    init() {
        // Use optimized configuration
        let config = IntelligenceConfiguration(
            performanceProfile: .optimized,
            enableCaching: true,
            maxCacheSize: .megabytes(100),
            enableParallelProcessing: true
        )
        
        self.aiEngine = IntelligenceEngine(configuration: config)
        
        // Initialize in background
        Task {
            try? await aiEngine.initialize()
        }
    }
    
    func processInBackground<T>(operation: @escaping () async throws -> T) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            backgroundQueue.async {
                Task {
                    do {
                        let result = try await operation()
                        continuation.resume(returning: result)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
}
```

## 🔗 Next Steps

Now that you have SwiftIntelligence set up, explore these advanced topics:

- **[API Reference](API-Reference.md)** - Complete API documentation
- **[Architecture Guide](Architecture.md)** - In-depth architecture overview
- **[Demo Applications](../Examples/)** - Real-world implementation examples
- **[visionOS Integration](visionOS-Guide.md)** - Spatial computing development
- **[Performance Optimization](Performance.md)** - Advanced performance tuning
- **[Security Guide](Security.md)** - Privacy and security best practices

## 💡 Example Projects

Check out the included demo applications:

1. **IntelligentCamera** - AI-powered camera with real-time analysis
2. **SmartTranslator** - Multi-language translation with cultural adaptation
3. **VoiceAssistant** - Natural conversation AI with contextual understanding
4. **ARCreativeStudio** - AR content creation with AI assistance
5. **PersonalAITutor** - Adaptive learning companion

Each demo showcases different aspects of the framework and provides production-ready code you can learn from and adapt to your needs.

Happy coding with SwiftIntelligence! 🚀