# SwiftIntelligence API Overview

This document describes the active public surface of the current modular package graph.

For installation and first-run setup, start with [Getting-Started.md](Getting-Started.md).

## Active Entry Points

| Product | Primary Entry Point |
| --- | --- |
| `SwiftIntelligenceCore` | `SwiftIntelligenceCore.shared` |
| `SwiftIntelligenceML` | `SwiftIntelligenceML` actor |
| `SwiftIntelligenceNLP` | `NLPEngine.shared` |
| `SwiftIntelligenceVision` | `VisionEngine.shared` |
| `SwiftIntelligenceSpeech` | `SpeechEngine.shared` and `SpeechEngine.availableVoices(for:)` |
| `SwiftIntelligencePrivacy` | `SwiftIntelligencePrivacy` actor and `PrivacyTokenizer` |

## Core Module

`SwiftIntelligenceCore` owns shared configuration, logging, performance monitoring, and error handling.

```swift
import SwiftIntelligenceCore

SwiftIntelligenceCore.shared.configure(with: .production)

let memory = SwiftIntelligenceCore.shared.memoryUsage()
let cpu = SwiftIntelligenceCore.shared.cpuUsage()
```

Important types:

- `IntelligenceConfiguration`
- `PerformanceProfile`
- `PrivacyLevel`
- `CachePolicy`
- `IntelligenceLogLevel`

Preset configurations:

- `IntelligenceConfiguration.development`
- `IntelligenceConfiguration.production`
- `IntelligenceConfiguration.testing`

## NLP Module

`NLPEngine` is a `@MainActor` singleton focused on text analysis and convenience APIs.

Verified public operations:

- `analyze(text:options:)`
- `analyzeSentiment(text:language:)`
- `extractNamedEntities(text:language:)`
- `extractKeywords(text:language:maxCount:)`
- `extractTopics(text:language:topicCount:)`
- `summarizeText(text:maxSentences:)`
- `translateText(_:from:to:)`

Example:

```swift
import SwiftIntelligenceNLP

let result = try await NLPEngine.shared.analyze(
    text: "Apple builds amazing products in Cupertino.",
    options: NLPOptions(
        includeSentiment: true,
        includeEntities: true,
        includeKeywords: true,
        includeLanguageDetection: true
    )
)
```

## Vision Module

`VisionEngine` is a `@MainActor` singleton. It must be initialized before use and shut down when you are done with long-lived sessions.

Verified public operations:

- `initialize()`
- `classifyImage(_:options:)`
- `batchClassifyImages(_:options:)`
- `detectObjects(in:options:)`
- `detectObjectsRealtime(from:options:)`
- `recognizeFaces(in:options:)`
- `enrollFace(from:identity:options:)`
- `recognizeText(in:options:)`
- `analyzeDocument(_:options:)`
- `segmentImage(_:options:)`
- `createCutoutMask(for:subject:)`
- `generateImage(from:options:)`
- `generateVariations(of:count:options:)`
- `enhanceImage(_:options:)`
- `denoiseImage(_:strength:)`
- `applyStyle(to:style:options:)`
- `applyCustomStyle(to:styleImage:options:)`
- `batchProcess(_:)`
- `optimizeMemory()`
- `shutdown()`

Example:

```swift
import SwiftIntelligenceVision

@MainActor
func runVision(image: PlatformImage) async throws {
    let engine = VisionEngine.shared
    try await engine.initialize()
    defer { Task { await engine.shutdown() } }

    let result = try await engine.detectObjects(in: image, options: .default)
    print(result.detectedObjects.count)
}
```

## Speech Module

`SpeechEngine` is a `@MainActor` singleton for recognition, synthesis, and voice discovery.

Verified public operations:

- `startSpeechRecognition(language:options:)`
- `stopSpeechRecognition()`
- `recognizeSpeech(from:language:options:)`
- `batchRecognizeSpeech(from:language:options:)`
- `synthesizeSpeech(from:voice:options:)`
- `generateSpeechAudio(from:voice:options:)`
- `getAvailableVoices(for:)`
- `SpeechEngine.availableVoices(for:)`
- `startRealtimeSpeechProcessing(language:options:)`

Example:

```swift
import SwiftIntelligenceSpeech

let voices = SpeechEngine.availableVoices(for: "en-US")
print(voices.map(\.name))
```

## ML Module

`SwiftIntelligenceML` is an actor that owns model registration, training, inference, evaluation, and cache operations.

Verified public operations:

- `registerModel(_:withID:)`
- `availableModels()`
- `removeModel(withID:)`
- `train(modelID:with:)`
- `predict(modelID:input:)`
- `batchPredict(modelID:inputs:)`
- `evaluate(modelID:testData:)`
- `getPerformanceMetrics()`
- `clearCache()`
- `getCacheStats()`
- `initialize()`
- `shutdown()`
- `validate()`
- `healthCheck()`

Example:

```swift
import SwiftIntelligenceML

let ml = try await SwiftIntelligenceML()
let models = await ml.availableModels()
print(models)
```

## Privacy Module

There are two practical entry points:

- `SwiftIntelligencePrivacy` actor for encryption, secure storage, anonymization, compliance, and audit operations
- `PrivacyTokenizer` for reversible tokenization of sensitive strings

Verified privacy actor operations include:

- `encryptData(_:algorithm:level:)`
- `decryptData(_:verifyIntegrity:)`
- `storeSecureData(_:key:options:)`
- `retrieveSecureData(key:options:)`
- `deleteSecureData(key:)`
- `authenticateWithBiometrics(reason:options:)`
- `anonymizeData(_:options:)`
- `applyPrivacyPolicy(_:to:)`
- `getAuditLog(filter:)`
- `clearAuditLog()`
- `exportAuditLog(format:)`

Verified tokenizer operations include:

- `tokenize(_:context:)`
- `detokenize(_:)`
- `tokenizeBatch(_:)`
- `detokenizeBatch(_:)`
- `formatPreservingTokenize(_:context:)`

## Non-Goals of This Document

This file intentionally does not document:

- legacy umbrella `IntelligenceEngine` APIs
- non-active products removed from the current package graph
- hypothetical cloud-provider integrations that are not part of the active build
