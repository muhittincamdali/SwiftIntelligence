# Getting Started with SwiftIntelligence

Learn how to integrate SwiftIntelligence into your app and start using AI/ML capabilities.

@Metadata {
    @PageImage(purpose: icon, source: "getting-started-icon")
    @PageColor(blue)
}

## Overview

SwiftIntelligence makes it easy to add powerful AI and machine learning capabilities to your Apple platform apps. This guide will walk you through the initial setup and basic usage.

## Installation

### Swift Package Manager

The recommended way to install SwiftIntelligence is through Swift Package Manager.

#### Using Xcode

1. In Xcode, select **File → Add Package Dependencies**
2. Enter the repository URL:
   ```
   https://github.com/username/SwiftIntelligence
   ```
3. Select the version rule (e.g., "Up to Next Major Version")
4. Choose the modules you need
5. Click **Add Package**

#### Using Package.swift

Add SwiftIntelligence to your `Package.swift` file:

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "YourApp",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    dependencies: [
        .package(
            url: "https://github.com/username/SwiftIntelligence",
            from: "1.0.0"
        )
    ],
    targets: [
        .target(
            name: "YourApp",
            dependencies: ["SwiftIntelligence"]
        )
    ]
)
```

## Basic Setup

### Import the Framework

```swift
import SwiftIntelligence
```

### Initialize the Engine

```swift
@main
struct MyApp: App {
    init() {
        Task {
            do {
                // Initialize SwiftIntelligence
                try await IntelligenceEngine.shared.initialize()
                print("SwiftIntelligence initialized successfully")
            } catch {
                print("Failed to initialize: \(error)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

## Your First AI Feature

Let's create a simple sentiment analysis feature:

```swift
import SwiftUI
import SwiftIntelligence

struct SentimentAnalyzerView: View {
    @State private var inputText = ""
    @State private var sentiment: String = ""
    @State private var isAnalyzing = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Sentiment Analyzer")
                .font(.largeTitle)
                .bold()
            
            TextEditor(text: $inputText)
                .frame(height: 100)
                .padding(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.5))
                )
            
            Button(action: analyzeSentiment) {
                if isAnalyzing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Text("Analyze Sentiment")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(inputText.isEmpty || isAnalyzing)
            
            if !sentiment.isEmpty {
                Text(sentiment)
                    .font(.headline)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding()
    }
    
    func analyzeSentiment() {
        isAnalyzing = true
        
        Task {
            do {
                let nlpEngine = try await IntelligenceEngine.shared
                    .getNaturalLanguageEngine()
                
                let result = try await nlpEngine.analyzeSentiment(inputText)
                
                await MainActor.run {
                    switch result.sentiment {
                    case .positive:
                        sentiment = "😊 Positive (confidence: \(Int(result.confidence * 100))%)"
                    case .negative:
                        sentiment = "😔 Negative (confidence: \(Int(result.confidence * 100))%)"
                    case .neutral:
                        sentiment = "😐 Neutral (confidence: \(Int(result.confidence * 100))%)"
                    }
                    isAnalyzing = false
                }
            } catch {
                await MainActor.run {
                    sentiment = "Error: \(error.localizedDescription)"
                    isAnalyzing = false
                }
            }
        }
    }
}
```

## Configuration Options

SwiftIntelligence can be configured to suit your app's needs:

```swift
// Create custom configuration
let config = IntelligenceConfiguration(
    enabledEngines: [.nlp, .vision, .speech],
    privacyLevel: .high,
    performanceProfile: .balanced,
    cachingPolicy: .automatic,
    loggingLevel: .info
)

// Apply configuration
try await IntelligenceEngine.shared.configure(with: config)
```

### Configuration Profiles

#### Development
```swift
let devConfig = IntelligenceConfiguration.development
// Verbose logging, all engines enabled
```

#### Production
```swift
let prodConfig = IntelligenceConfiguration.production
// Optimized performance, minimal logging
```

#### Testing
```swift
let testConfig = IntelligenceConfiguration.testing
// Predictable behavior for unit tests
```

## Permissions

Some features require specific permissions:

### Speech Recognition

Add to `Info.plist`:
```xml
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app uses speech recognition to process voice commands.</string>

<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for speech recognition.</string>
```

### Camera (for Vision features)

```xml
<key>NSCameraUsageDescription</key>
<string>This app uses the camera for image analysis.</string>
```

### Photo Library

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>This app analyzes photos from your library.</string>
```

## Error Handling

SwiftIntelligence uses Swift's error handling:

```swift
do {
    let result = try await nlpEngine.analyzeText(text)
    // Handle successful result
} catch IntelligenceError.engineNotInitialized {
    // Handle initialization error
} catch IntelligenceError.processingFailed(let reason) {
    // Handle processing error
    print("Processing failed: \(reason)")
} catch {
    // Handle other errors
    print("Unexpected error: \(error)")
}
```

## Best Practices

### 1. Initialize Early

Initialize SwiftIntelligence during app startup to avoid delays:

```swift
@main
struct MyApp: App {
    init() {
        Task {
            try? await IntelligenceEngine.shared.initialize()
        }
    }
}
```

### 2. Handle Errors Gracefully

Always provide fallback behavior:

```swift
func processText(_ text: String) async -> String {
    do {
        let result = try await nlpEngine.analyzeText(text)
        return result.summary
    } catch {
        // Fallback to basic processing
        return text.prefix(100) + "..."
    }
}
```

### 3. Use Appropriate Quality of Service

```swift
Task(priority: .userInitiated) {
    // High-priority AI tasks
}

Task(priority: .background) {
    // Low-priority batch processing
}
```

### 4. Monitor Performance

```swift
let metrics = await IntelligenceEngine.shared.getPerformanceMetrics()
print("Average inference time: \(metrics.averageInferenceTime)ms")
```

## Next Steps

- Explore <doc:BasicConcepts> to understand the framework architecture
- Check out <doc:Tutorials> for more detailed examples
- Review <doc:BestPractices> for production deployment
- See <doc:APIReference> for complete documentation

## Sample Projects

We provide several sample projects demonstrating various features:

- **ChatBot**: Natural language conversation app
- **ImageAnalyzer**: Computer vision demonstration
- **VoiceAssistant**: Speech recognition and synthesis
- **SmartCamera**: Real-time object detection

Find them in the [Examples](https://github.com/username/SwiftIntelligence/tree/main/Examples) directory.

## Troubleshooting

### Common Issues

**Framework not initializing**
- Ensure you're using the correct minimum OS versions
- Check that you've added required permissions to Info.plist

**Poor performance**
- Use appropriate performance profile in configuration
- Consider using background queues for heavy processing
- Enable caching for repeated operations

**Memory issues**
- The framework automatically manages memory
- For large datasets, use streaming APIs when available

## Getting Help

- **Documentation**: [API Reference](https://github.com/username/SwiftIntelligence/wiki)
- **Issues**: [GitHub Issues](https://github.com/username/SwiftIntelligence/issues)
- **Discussions**: [GitHub Discussions](https://github.com/username/SwiftIntelligence/discussions)
- **Stack Overflow**: Tag your questions with `swiftintelligence`