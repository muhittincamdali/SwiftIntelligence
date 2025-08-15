import Foundation
import NaturalLanguage
import os.log

/// Advanced configuration system for Natural Language Processing operations
public struct NLPConfiguration {
    
    // MARK: - Core Settings
    public let enableTurkishNLP: Bool
    public let maxCacheSize: Int
    public let enableLogging: Bool
    public let preferredLanguages: [NLLanguage]
    public let processingTimeout: TimeInterval
    
    // MARK: - Model Settings
    public let modelLoadingStrategy: ModelLoadingStrategy
    public let maxConcurrentOperations: Int
    public let memoryOptimization: Bool
    
    // MARK: - Analysis Settings
    public let defaultSentimentThreshold: Float
    public let entityExtractionThreshold: Float
    public let keywordExtractionMethod: KeywordExtractionMethod
    public let topicModelingAlgorithm: TopicModelingAlgorithm
    
    // MARK: - Language-Specific Settings
    public let turkishMorphologyEnabled: Bool
    public let multilanguageDetection: Bool
    public let translationCacheEnabled: Bool
    
    // MARK: - Performance Settings
    public let batchProcessingEnabled: Bool
    public let streamingProcessing: Bool
    public let resultCaching: Bool
    
    public init(
        enableTurkishNLP: Bool = true,
        maxCacheSize: Int = 1000,
        enableLogging: Bool = true,
        preferredLanguages: [NLLanguage] = [.english, .turkish],
        processingTimeout: TimeInterval = 30.0,
        modelLoadingStrategy: ModelLoadingStrategy = .lazy,
        maxConcurrentOperations: Int = 4,
        memoryOptimization: Bool = true,
        defaultSentimentThreshold: Float = 0.6,
        entityExtractionThreshold: Float = 0.7,
        keywordExtractionMethod: KeywordExtractionMethod = .tfidf,
        topicModelingAlgorithm: TopicModelingAlgorithm = .lda,
        turkishMorphologyEnabled: Bool = true,
        multilanguageDetection: Bool = true,
        translationCacheEnabled: Bool = true,
        batchProcessingEnabled: Bool = true,
        streamingProcessing: Bool = false,
        resultCaching: Bool = true
    ) {
        self.enableTurkishNLP = enableTurkishNLP
        self.maxCacheSize = maxCacheSize
        self.enableLogging = enableLogging
        self.preferredLanguages = preferredLanguages
        self.processingTimeout = processingTimeout
        self.modelLoadingStrategy = modelLoadingStrategy
        self.maxConcurrentOperations = maxConcurrentOperations
        self.memoryOptimization = memoryOptimization
        self.defaultSentimentThreshold = defaultSentimentThreshold
        self.entityExtractionThreshold = entityExtractionThreshold
        self.keywordExtractionMethod = keywordExtractionMethod
        self.topicModelingAlgorithm = topicModelingAlgorithm
        self.turkishMorphologyEnabled = turkishMorphologyEnabled
        self.multilanguageDetection = multilanguageDetection
        self.translationCacheEnabled = translationCacheEnabled
        self.batchProcessingEnabled = batchProcessingEnabled
        self.streamingProcessing = streamingProcessing
        self.resultCaching = resultCaching
    }
}

// MARK: - Predefined Configurations

extension NLPConfiguration {
    
    /// Default configuration with balanced performance and accuracy
    public static let `default` = NLPConfiguration()
    
    /// High-performance configuration optimized for speed
    public static let performance = NLPConfiguration(
        enableTurkishNLP: false,
        maxCacheSize: 500,
        enableLogging: false,
        preferredLanguages: [.english],
        processingTimeout: 15.0,
        modelLoadingStrategy: .preload,
        maxConcurrentOperations: 8,
        memoryOptimization: true,
        keywordExtractionMethod: .frequency,
        topicModelingAlgorithm: .simple,
        turkishMorphologyEnabled: false,
        multilanguageDetection: false,
        batchProcessingEnabled: true
    )
    
    /// Comprehensive configuration with all features enabled
    public static let comprehensive = NLPConfiguration(
        enableTurkishNLP: true,
        maxCacheSize: 2000,
        enableLogging: true,
        preferredLanguages: [.english, .turkish, .spanish, .french, .german, .italian, .portuguese],
        processingTimeout: 60.0,
        modelLoadingStrategy: .preload,
        maxConcurrentOperations: 6,
        memoryOptimization: false,
        defaultSentimentThreshold: 0.5,
        entityExtractionThreshold: 0.6,
        keywordExtractionMethod: .tfidf,
        topicModelingAlgorithm: .lda,
        turkishMorphologyEnabled: true,
        multilanguageDetection: true,
        translationCacheEnabled: true,
        batchProcessingEnabled: true,
        streamingProcessing: true
    )
    
    /// Memory-efficient configuration for resource-constrained environments
    public static let memoryEfficient = NLPConfiguration(
        enableTurkishNLP: false,
        maxCacheSize: 100,
        enableLogging: false,
        preferredLanguages: [.english, .turkish],
        processingTimeout: 10.0,
        modelLoadingStrategy: .lazy,
        maxConcurrentOperations: 2,
        memoryOptimization: true,
        keywordExtractionMethod: .frequency,
        topicModelingAlgorithm: .simple,
        turkishMorphologyEnabled: false,
        multilanguageDetection: false,
        translationCacheEnabled: false,
        batchProcessingEnabled: false
    )
    
    /// Turkish-focused configuration optimized for Turkish language processing
    public static let turkishOptimized = NLPConfiguration(
        enableTurkishNLP: true,
        maxCacheSize: 1500,
        enableLogging: true,
        preferredLanguages: [.turkish, .english],
        processingTimeout: 45.0,
        modelLoadingStrategy: .preload,
        maxConcurrentOperations: 4,
        memoryOptimization: false,
        defaultSentimentThreshold: 0.65,
        entityExtractionThreshold: 0.75,
        keywordExtractionMethod: .tfidf,
        topicModelingAlgorithm: .lda,
        turkishMorphologyEnabled: true,
        multilanguageDetection: true,
        translationCacheEnabled: true,
        batchProcessingEnabled: true
    )
    
    /// Enterprise configuration for production environments
    public static let enterprise = NLPConfiguration(
        enableTurkishNLP: true,
        maxCacheSize: 5000,
        enableLogging: true,
        preferredLanguages: [.english, .turkish, .spanish, .french, .german],
        processingTimeout: 120.0,
        modelLoadingStrategy: .preload,
        maxConcurrentOperations: 12,
        memoryOptimization: false,
        defaultSentimentThreshold: 0.7,
        entityExtractionThreshold: 0.8,
        keywordExtractionMethod: .tfidf,
        topicModelingAlgorithm: .lda,
        turkishMorphologyEnabled: true,
        multilanguageDetection: true,
        translationCacheEnabled: true,
        batchProcessingEnabled: true,
        streamingProcessing: true
    )
    
    /// Privacy-focused configuration with minimal data retention
    public static let privacyFocused = NLPConfiguration(
        enableTurkishNLP: false,
        maxCacheSize: 0,
        enableLogging: false,
        preferredLanguages: [.english],
        processingTimeout: 20.0,
        modelLoadingStrategy: .lazy,
        maxConcurrentOperations: 2,
        memoryOptimization: true,
        translationCacheEnabled: false,
        resultCaching: false
    )
}

// MARK: - Configuration Enums

public enum ModelLoadingStrategy {
    case lazy          // Load models on demand
    case preload       // Load all models at startup
    case selective     // Load based on usage patterns
}

public enum KeywordExtractionMethod {
    case frequency     // Simple word frequency
    case tfidf        // Term Frequency-Inverse Document Frequency
    case rake         // Rapid Automatic Keyword Extraction
    case textrank     // PageRank-based keyword extraction
}

public enum TopicModelingAlgorithm {
    case simple       // Simple keyword clustering
    case lda          // Latent Dirichlet Allocation
    case nmf          // Non-negative Matrix Factorization
    case bert         // BERT-based topic modeling
}

// MARK: - Configuration Validation

extension NLPConfiguration {
    
    /// Validates the configuration and returns warnings if any
    public func validate() -> [ConfigurationWarning] {
        var warnings: [ConfigurationWarning] = []
        
        // Check cache size
        if maxCacheSize > 10000 {
            warnings.append(.largeCacheSize(maxCacheSize))
        }
        
        // Check concurrent operations
        if maxConcurrentOperations > ProcessInfo.processInfo.processorCount * 2 {
            warnings.append(.excessiveConcurrency(maxConcurrentOperations))
        }
        
        // Check timeout
        if processingTimeout < 5.0 {
            warnings.append(.shortTimeout(processingTimeout))
        }
        
        // Check language support
        if preferredLanguages.isEmpty {
            warnings.append(.noPreferredLanguages)
        }
        
        // Check Turkish NLP without Turkish language
        if enableTurkishNLP && !preferredLanguages.contains(.turkish) {
            warnings.append(.turkishNLPWithoutTurkishLanguage)
        }
        
        return warnings
    }
}

public enum ConfigurationWarning {
    case largeCacheSize(Int)
    case excessiveConcurrency(Int)
    case shortTimeout(TimeInterval)
    case noPreferredLanguages
    case turkishNLPWithoutTurkishLanguage
    
    public var message: String {
        switch self {
        case .largeCacheSize(let size):
            return "Large cache size (\(size)) may consume significant memory"
        case .excessiveConcurrency(let count):
            return "High concurrent operations (\(count)) may impact performance"
        case .shortTimeout(let timeout):
            return "Short timeout (\(timeout)s) may cause processing failures"
        case .noPreferredLanguages:
            return "No preferred languages specified"
        case .turkishNLPWithoutTurkishLanguage:
            return "Turkish NLP enabled but Turkish not in preferred languages"
        }
    }
}

// MARK: - Configuration Builder

public class NLPConfigurationBuilder {
    private var config = NLPConfiguration()
    
    public init() {}
    
    public func enableTurkishNLP(_ enable: Bool = true) -> Self {
        config = NLPConfiguration(
            enableTurkishNLP: enable,
            maxCacheSize: config.maxCacheSize,
            enableLogging: config.enableLogging,
            preferredLanguages: config.preferredLanguages,
            processingTimeout: config.processingTimeout,
            modelLoadingStrategy: config.modelLoadingStrategy,
            maxConcurrentOperations: config.maxConcurrentOperations,
            memoryOptimization: config.memoryOptimization,
            defaultSentimentThreshold: config.defaultSentimentThreshold,
            entityExtractionThreshold: config.entityExtractionThreshold,
            keywordExtractionMethod: config.keywordExtractionMethod,
            topicModelingAlgorithm: config.topicModelingAlgorithm,
            turkishMorphologyEnabled: config.turkishMorphologyEnabled,
            multilanguageDetection: config.multilanguageDetection,
            translationCacheEnabled: config.translationCacheEnabled,
            batchProcessingEnabled: config.batchProcessingEnabled,
            streamingProcessing: config.streamingProcessing,
            resultCaching: config.resultCaching
        )
        return self
    }
    
    public func setCacheSize(_ size: Int) -> Self {
        config = NLPConfiguration(
            enableTurkishNLP: config.enableTurkishNLP,
            maxCacheSize: size,
            enableLogging: config.enableLogging,
            preferredLanguages: config.preferredLanguages,
            processingTimeout: config.processingTimeout,
            modelLoadingStrategy: config.modelLoadingStrategy,
            maxConcurrentOperations: config.maxConcurrentOperations,
            memoryOptimization: config.memoryOptimization,
            defaultSentimentThreshold: config.defaultSentimentThreshold,
            entityExtractionThreshold: config.entityExtractionThreshold,
            keywordExtractionMethod: config.keywordExtractionMethod,
            topicModelingAlgorithm: config.topicModelingAlgorithm,
            turkishMorphologyEnabled: config.turkishMorphologyEnabled,
            multilanguageDetection: config.multilanguageDetection,
            translationCacheEnabled: config.translationCacheEnabled,
            batchProcessingEnabled: config.batchProcessingEnabled,
            streamingProcessing: config.streamingProcessing,
            resultCaching: config.resultCaching
        )
        return self
    }
    
    public func setPreferredLanguages(_ languages: [NLLanguage]) -> Self {
        config = NLPConfiguration(
            enableTurkishNLP: config.enableTurkishNLP,
            maxCacheSize: config.maxCacheSize,
            enableLogging: config.enableLogging,
            preferredLanguages: languages,
            processingTimeout: config.processingTimeout,
            modelLoadingStrategy: config.modelLoadingStrategy,
            maxConcurrentOperations: config.maxConcurrentOperations,
            memoryOptimization: config.memoryOptimization,
            defaultSentimentThreshold: config.defaultSentimentThreshold,
            entityExtractionThreshold: config.entityExtractionThreshold,
            keywordExtractionMethod: config.keywordExtractionMethod,
            topicModelingAlgorithm: config.topicModelingAlgorithm,
            turkishMorphologyEnabled: config.turkishMorphologyEnabled,
            multilanguageDetection: config.multilanguageDetection,
            translationCacheEnabled: config.translationCacheEnabled,
            batchProcessingEnabled: config.batchProcessingEnabled,
            streamingProcessing: config.streamingProcessing,
            resultCaching: config.resultCaching
        )
        return self
    }
    
    public func setModelLoadingStrategy(_ strategy: ModelLoadingStrategy) -> Self {
        config = NLPConfiguration(
            enableTurkishNLP: config.enableTurkishNLP,
            maxCacheSize: config.maxCacheSize,
            enableLogging: config.enableLogging,
            preferredLanguages: config.preferredLanguages,
            processingTimeout: config.processingTimeout,
            modelLoadingStrategy: strategy,
            maxConcurrentOperations: config.maxConcurrentOperations,
            memoryOptimization: config.memoryOptimization,
            defaultSentimentThreshold: config.defaultSentimentThreshold,
            entityExtractionThreshold: config.entityExtractionThreshold,
            keywordExtractionMethod: config.keywordExtractionMethod,
            topicModelingAlgorithm: config.topicModelingAlgorithm,
            turkishMorphologyEnabled: config.turkishMorphologyEnabled,
            multilanguageDetection: config.multilanguageDetection,
            translationCacheEnabled: config.translationCacheEnabled,
            batchProcessingEnabled: config.batchProcessingEnabled,
            streamingProcessing: config.streamingProcessing,
            resultCaching: config.resultCaching
        )
        return self
    }
    
    public func enableMemoryOptimization(_ enable: Bool = true) -> Self {
        config = NLPConfiguration(
            enableTurkishNLP: config.enableTurkishNLP,
            maxCacheSize: config.maxCacheSize,
            enableLogging: config.enableLogging,
            preferredLanguages: config.preferredLanguages,
            processingTimeout: config.processingTimeout,
            modelLoadingStrategy: config.modelLoadingStrategy,
            maxConcurrentOperations: config.maxConcurrentOperations,
            memoryOptimization: enable,
            defaultSentimentThreshold: config.defaultSentimentThreshold,
            entityExtractionThreshold: config.entityExtractionThreshold,
            keywordExtractionMethod: config.keywordExtractionMethod,
            topicModelingAlgorithm: config.topicModelingAlgorithm,
            turkishMorphologyEnabled: config.turkishMorphologyEnabled,
            multilanguageDetection: config.multilanguageDetection,
            translationCacheEnabled: config.translationCacheEnabled,
            batchProcessingEnabled: config.batchProcessingEnabled,
            streamingProcessing: config.streamingProcessing,
            resultCaching: config.resultCaching
        )
        return self
    }
    
    public func build() -> NLPConfiguration {
        return config
    }
}

// MARK: - Configuration Extensions

extension NLPConfiguration {
    
    /// Creates a configuration optimized for the current device
    public static func optimizedForDevice() -> NLPConfiguration {
        let processorCount = ProcessInfo.processInfo.processorCount
        let memorySize = ProcessInfo.processInfo.physicalMemory
        
        // Adjust settings based on device capabilities
        let maxConcurrency = max(2, min(8, processorCount))
        let cacheSize = memorySize > 4_000_000_000 ? 2000 : 1000 // 4GB threshold
        let enableAdvanced = memorySize > 2_000_000_000 // 2GB threshold
        
        return NLPConfiguration(
            enableTurkishNLP: enableAdvanced,
            maxCacheSize: cacheSize,
            maxConcurrentOperations: maxConcurrency,
            memoryOptimization: memorySize < 4_000_000_000,
            topicModelingAlgorithm: enableAdvanced ? .lda : .simple,
            batchProcessingEnabled: enableAdvanced
        )
    }
    
    /// Creates a configuration based on user preferences
    public static func forUserPreferences(
        languages: [NLLanguage],
        performancePriority: Bool = false,
        privacyMode: Bool = false
    ) -> NLPConfiguration {
        
        if privacyMode {
            return .privacyFocused
        }
        
        if performancePriority {
            return NLPConfiguration.performance
                .withPreferredLanguages(languages)
        }
        
        return NLPConfiguration.default
            .withPreferredLanguages(languages)
            .withTurkishNLP(languages.contains(.turkish))
    }
}

// MARK: - Configuration Modification

extension NLPConfiguration {
    
    func withPreferredLanguages(_ languages: [NLLanguage]) -> NLPConfiguration {
        return NLPConfiguration(
            enableTurkishNLP: self.enableTurkishNLP,
            maxCacheSize: self.maxCacheSize,
            enableLogging: self.enableLogging,
            preferredLanguages: languages,
            processingTimeout: self.processingTimeout,
            modelLoadingStrategy: self.modelLoadingStrategy,
            maxConcurrentOperations: self.maxConcurrentOperations,
            memoryOptimization: self.memoryOptimization,
            defaultSentimentThreshold: self.defaultSentimentThreshold,
            entityExtractionThreshold: self.entityExtractionThreshold,
            keywordExtractionMethod: self.keywordExtractionMethod,
            topicModelingAlgorithm: self.topicModelingAlgorithm,
            turkishMorphologyEnabled: self.turkishMorphologyEnabled,
            multilanguageDetection: self.multilanguageDetection,
            translationCacheEnabled: self.translationCacheEnabled,
            batchProcessingEnabled: self.batchProcessingEnabled,
            streamingProcessing: self.streamingProcessing,
            resultCaching: self.resultCaching
        )
    }
    
    func withTurkishNLP(_ enable: Bool) -> NLPConfiguration {
        return NLPConfiguration(
            enableTurkishNLP: enable,
            maxCacheSize: self.maxCacheSize,
            enableLogging: self.enableLogging,
            preferredLanguages: self.preferredLanguages,
            processingTimeout: self.processingTimeout,
            modelLoadingStrategy: self.modelLoadingStrategy,
            maxConcurrentOperations: self.maxConcurrentOperations,
            memoryOptimization: self.memoryOptimization,
            defaultSentimentThreshold: self.defaultSentimentThreshold,
            entityExtractionThreshold: self.entityExtractionThreshold,
            keywordExtractionMethod: self.keywordExtractionMethod,
            topicModelingAlgorithm: self.topicModelingAlgorithm,
            turkishMorphologyEnabled: enable,
            multilanguageDetection: self.multilanguageDetection,
            translationCacheEnabled: self.translationCacheEnabled,
            batchProcessingEnabled: self.batchProcessingEnabled,
            streamingProcessing: self.streamingProcessing,
            resultCaching: self.resultCaching
        )
    }
}