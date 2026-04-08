# SwiftIntelligence API Reference

This file is a concise, current reference for the active modular graph. It is not intended to mirror generated symbol docs.

## Core

### `SwiftIntelligenceCore`

```swift
@MainActor
public final class SwiftIntelligenceCore: ObservableObject
```

Primary members:

- `static let shared`
- `static let version`
- `static let buildNumber`
- `configure(with:)`
- `resetConfiguration()`
- `cleanup()`
- `memoryUsage()`
- `cpuUsage()`

### `IntelligenceConfiguration`

```swift
public struct IntelligenceConfiguration: Sendable
```

Common presets:

- `development`
- `production`
- `testing`

Selected fields:

- `debugMode`
- `performanceMonitoring`
- `verboseLogging`
- `memoryLimit`
- `requestTimeout`
- `cacheDuration`
- `maxConcurrentOperations`
- `privacyMode`
- `telemetryEnabled`
- `enableOnDeviceProcessing`
- `enableCloudFallback`
- `enableNeuralEngine`
- `batchSize`
- `logLevel`
- `performanceProfile`
- `privacyLevel`
- `cachePolicy`

## NLP

### `NLPEngine`

```swift
@MainActor
public class NLPEngine: ObservableObject
```

Primary members:

- `static let shared`
- `analyze(text:options:)`
- `analyzeSentiment(text:language:)`
- `extractNamedEntities(text:language:)`
- `extractKeywords(text:language:maxCount:)`
- `extractTopics(text:language:topicCount:)`
- `summarizeText(text:maxSentences:)`
- `translateText(_:from:to:)`

### `NLPOptions`

```swift
public struct NLPOptions: Hashable, Codable, Sendable
```

Common toggles:

- `includeSentiment`
- `includeEntities`
- `includeKeywords`
- `includeTopics`
- `includeLanguageDetection`
- `includeReadability`

## Vision

### `VisionEngine`

```swift
@MainActor
public class VisionEngine: ObservableObject
```

Lifecycle:

- `static let shared`
- `initialize()`
- `shutdown()`
- `optimizeMemory()`
- `getProcessingStats()`

Classification and detection:

- `classifyImage(_:options:)`
- `batchClassifyImages(_:options:)`
- `detectObjects(in:options:)`
- `detectObjectsRealtime(from:options:)`
- `recognizeFaces(in:options:)`
- `enrollFace(from:identity:options:)`

OCR and segmentation:

- `recognizeText(in:options:)`
- `analyzeDocument(_:options:)`
- `segmentImage(_:options:)`
- `createCutoutMask(for:subject:)`

Generation and enhancement:

- `generateImage(from:options:)`
- `generateVariations(of:count:options:)`
- `enhanceImage(_:options:)`
- `denoiseImage(_:strength:)`
- `applyStyle(to:style:options:)`
- `applyCustomStyle(to:styleImage:options:)`

Batch:

- `batchProcess(_:)`

Common option types:

- `ClassificationOptions`
- `DetectionOptions`
- `FaceRecognitionOptions`
- `TextRecognitionOptions`
- `SegmentationOptions`
- `ImageGenerationOptions`
- `EnhancementOptions`
- `StyleTransferOptions`

## Speech

### `SpeechEngine`

```swift
@MainActor
public class SpeechEngine: NSObject, ObservableObject
```

Primary members:

- `static let shared`
- `startSpeechRecognition(language:options:)`
- `stopSpeechRecognition()`
- `recognizeSpeech(from:language:options:)`
- `batchRecognizeSpeech(from:language:options:)`
- `synthesizeSpeech(from:voice:options:)`
- `generateSpeechAudio(from:voice:options:)`
- `getAvailableVoices(for:)`
- `static availableVoices(for:)`
- `startRealtimeSpeechProcessing(language:options:)`

Common option types:

- `SpeechRecognitionOptions`
- `SpeechSynthesisOptions`
- `TextToSpeechOptions`

## ML

### `SwiftIntelligenceML`

```swift
public actor SwiftIntelligenceML
```

Primary members:

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

Common data types:

- `MLInput`
- `MLOutput`
- `MLTrainingData`
- `MLTrainingResult`
- `MLTestData`
- `MLEvaluationResult`

Default built-in model IDs:

- `"classification"`
- `"linear_regression"`

## Privacy

### `SwiftIntelligencePrivacy`

```swift
public actor SwiftIntelligencePrivacy
```

Primary members:

- `encryptData(_:algorithm:level:)`
- `decryptData(_:verifyIntegrity:)`
- `storeSecureData(_:key:options:)`
- `retrieveSecureData(key:options:)`
- `deleteSecureData(key:)`
- `authenticateWithBiometrics(reason:options:)`
- `anonymizeData(_:options:)`
- `applyPrivacyPolicy(_:to:)`
- `getPrivacyPolicy(id:)`
- `getAllPrivacyPolicies()`
- `getAuditLog(filter:)`
- `clearAuditLog()`
- `exportAuditLog(format:)`
- `scanForSensitiveData(_:)`
- `getPerformanceMetrics()`
- `getConfiguration()`
- `updateConfiguration(_:)`
- `initialize()`
- `shutdown()`
- `validate()`
- `healthCheck()`

### `PrivacyTokenizer`

```swift
public class PrivacyTokenizer: @unchecked Sendable
```

Primary members:

- `tokenize(_:context:)`
- `detokenize(_:)`
- `tokenizeBatch(_:)`
- `detokenizeBatch(_:)`
- `formatPreservingTokenize(_:context:)`

Primary context type:

- `TokenizationContext`

## Reference Boundary

This reference intentionally excludes:

- removed umbrella APIs
- inactive package products
- generated docs for every individual model or type

If a symbol here disagrees with the code, the code wins and this document should be updated immediately.
