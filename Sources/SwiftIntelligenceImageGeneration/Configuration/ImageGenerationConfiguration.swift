import Foundation
import UIKit

/// Advanced configuration system for Image Generation Engine
public struct ImageGenerationEngineConfiguration {
    
    // MARK: - Provider Configurations
    public let providers: ProviderConfigurations
    public let defaultProvider: ImageProvider
    
    // MARK: - Performance Settings
    public let performance: PerformanceSettings
    
    // MARK: - Quality Settings
    public let quality: QualitySettings
    
    // MARK: - Cache Settings
    public let caching: CacheSettings
    
    // MARK: - Rate Limiting
    public let rateLimiting: RateLimitSettings
    
    // MARK: - Local Processing
    public let localProcessing: LocalProcessingSettings
    
    // MARK: - Security Settings
    public let security: SecuritySettings
    
    public init(
        providers: ProviderConfigurations,
        defaultProvider: ImageProvider = .openai,
        performance: PerformanceSettings = .default,
        quality: QualitySettings = .default,
        caching: CacheSettings = .default,
        rateLimiting: RateLimitSettings = .default,
        localProcessing: LocalProcessingSettings = .default,
        security: SecuritySettings = .default
    ) {
        self.providers = providers
        self.defaultProvider = defaultProvider
        self.performance = performance
        self.quality = quality
        self.caching = caching
        self.rateLimiting = rateLimiting
        self.localProcessing = localProcessing
        self.security = security
    }
}

// MARK: - Provider Configurations

public struct ProviderConfigurations {
    public let openAI: OpenAIImageConfiguration?
    public let midjourney: MidjourneyConfiguration?
    public let stabilityAI: StabilityAIConfiguration?
    public let local: LocalImageConfiguration
    
    public init(
        openAI: OpenAIImageConfiguration? = nil,
        midjourney: MidjourneyConfiguration? = nil,
        stabilityAI: StabilityAIConfiguration? = nil,
        local: LocalImageConfiguration = .default
    ) {
        self.openAI = openAI
        self.midjourney = midjourney
        self.stabilityAI = stabilityAI
        self.local = local
    }
}

public struct OpenAIImageConfiguration {
    public let apiKey: String
    public let baseURL: String
    public let defaultModel: String
    public let maxRetries: Int
    public let timeout: TimeInterval
    
    public init(
        apiKey: String,
        baseURL: String = "https://api.openai.com/v1",
        defaultModel: String = "dall-e-3",
        maxRetries: Int = 3,
        timeout: TimeInterval = 120.0
    ) {
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.defaultModel = defaultModel
        self.maxRetries = maxRetries
        self.timeout = timeout
    }
}

public struct MidjourneyConfiguration {
    public let apiKey: String
    public let baseURL: String
    public let defaultVersion: String
    public let maxPollingTime: TimeInterval
    public let pollingInterval: TimeInterval
    
    public init(
        apiKey: String,
        baseURL: String = "https://api.midjourney.com/v1",
        defaultVersion: String = "6",
        maxPollingTime: TimeInterval = 300.0,
        pollingInterval: TimeInterval = 5.0
    ) {
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.defaultVersion = defaultVersion
        self.maxPollingTime = maxPollingTime
        self.pollingInterval = pollingInterval
    }
}

public struct StabilityAIConfiguration {
    public let apiKey: String
    public let baseURL: String
    public let defaultEngine: String
    public let maxRetries: Int
    public let timeout: TimeInterval
    
    public init(
        apiKey: String,
        baseURL: String = "https://api.stability.ai/v1",
        defaultEngine: String = "stable-diffusion-xl-1024-v1-0",
        maxRetries: Int = 3,
        timeout: TimeInterval = 120.0
    ) {
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.defaultEngine = defaultEngine
        self.maxRetries = maxRetries
        self.timeout = timeout
    }
}

public struct LocalImageConfiguration {
    public let enableTextToImage: Bool
    public let enableStyleTransfer: Bool
    public let enableUpscaling: Bool
    public let enableInpainting: Bool
    public let modelPath: String?
    public let maxConcurrency: Int
    
    public init(
        enableTextToImage: Bool = true,
        enableStyleTransfer: Bool = true,
        enableUpscaling: Bool = true,
        enableInpainting: Bool = true,
        modelPath: String? = nil,
        maxConcurrency: Int = 2
    ) {
        self.enableTextToImage = enableTextToImage
        self.enableStyleTransfer = enableStyleTransfer
        self.enableUpscaling = enableUpscaling
        self.enableInpainting = enableInpainting
        self.modelPath = modelPath
        self.maxConcurrency = maxConcurrency
    }
    
    public static let `default` = LocalImageConfiguration()
}

// MARK: - Performance Settings

public struct PerformanceSettings {
    public let maxConcurrentRequests: Int
    public let requestTimeout: TimeInterval
    public let enableBatching: Bool
    public let batchSize: Int
    public let priorityQueue: Bool
    
    public init(
        maxConcurrentRequests: Int = 3,
        requestTimeout: TimeInterval = 180.0,
        enableBatching: Bool = true,
        batchSize: Int = 5,
        priorityQueue: Bool = true
    ) {
        self.maxConcurrentRequests = maxConcurrentRequests
        self.requestTimeout = requestTimeout
        self.enableBatching = enableBatching
        self.batchSize = batchSize
        self.priorityQueue = priorityQueue
    }
    
    public static let `default` = PerformanceSettings()
    
    public static let highPerformance = PerformanceSettings(
        maxConcurrentRequests: 5,
        requestTimeout: 300.0,
        enableBatching: true,
        batchSize: 10,
        priorityQueue: true
    )
    
    public static let conservative = PerformanceSettings(
        maxConcurrentRequests: 1,
        requestTimeout: 120.0,
        enableBatching: false,
        batchSize: 1,
        priorityQueue: false
    )
}

// MARK: - Quality Settings

public struct QualitySettings {
    public let defaultResolution: ImageResolution
    public let defaultQuality: ImageQuality
    public let defaultStyle: ImageStyle
    public let enableEnhancement: Bool
    public let autoUpscale: Bool
    public let qualityThreshold: Float
    
    public init(
        defaultResolution: ImageResolution = .large,
        defaultQuality: ImageQuality = .standard,
        defaultStyle: ImageStyle = .natural,
        enableEnhancement: Bool = true,
        autoUpscale: Bool = false,
        qualityThreshold: Float = 0.8
    ) {
        self.defaultResolution = defaultResolution
        self.defaultQuality = defaultQuality
        self.defaultStyle = defaultStyle
        self.enableEnhancement = enableEnhancement
        self.autoUpscale = autoUpscale
        self.qualityThreshold = qualityThreshold
    }
    
    public static let `default` = QualitySettings()
    
    public static let highQuality = QualitySettings(
        defaultResolution: .xlarge,
        defaultQuality: .hd,
        defaultStyle: .photorealistic,
        enableEnhancement: true,
        autoUpscale: true,
        qualityThreshold: 0.9
    )
    
    public static let balanced = QualitySettings(
        defaultResolution: .large,
        defaultQuality: .standard,
        defaultStyle: .natural,
        enableEnhancement: true,
        autoUpscale: false,
        qualityThreshold: 0.75
    )
    
    public static let fast = QualitySettings(
        defaultResolution: .medium,
        defaultQuality: .standard,
        defaultStyle: .natural,
        enableEnhancement: false,
        autoUpscale: false,
        qualityThreshold: 0.6
    )
}

// MARK: - Cache Settings

public struct CacheSettings {
    public let enableImageCache: Bool
    public let enableResultCache: Bool
    public let maxCacheSize: Int
    public let maxCacheAge: TimeInterval
    public let compressionEnabled: Bool
    public let persistToDisk: Bool
    
    public init(
        enableImageCache: Bool = true,
        enableResultCache: Bool = true,
        maxCacheSize: Int = 100_000_000, // 100MB
        maxCacheAge: TimeInterval = 86400, // 24 hours
        compressionEnabled: Bool = true,
        persistToDisk: Bool = false
    ) {
        self.enableImageCache = enableImageCache
        self.enableResultCache = enableResultCache
        self.maxCacheSize = maxCacheSize
        self.maxCacheAge = maxCacheAge
        self.compressionEnabled = compressionEnabled
        self.persistToDisk = persistToDisk
    }
    
    public static let `default` = CacheSettings()
    
    public static let aggressive = CacheSettings(
        enableImageCache: true,
        enableResultCache: true,
        maxCacheSize: 500_000_000, // 500MB
        maxCacheAge: 604800, // 7 days
        compressionEnabled: true,
        persistToDisk: true
    )
    
    public static let minimal = CacheSettings(
        enableImageCache: true,
        enableResultCache: false,
        maxCacheSize: 50_000_000, // 50MB
        maxCacheAge: 3600, // 1 hour
        compressionEnabled: true,
        persistToDisk: false
    )
    
    public static let disabled = CacheSettings(
        enableImageCache: false,
        enableResultCache: false,
        maxCacheSize: 0,
        maxCacheAge: 0,
        compressionEnabled: false,
        persistToDisk: false
    )
}

// MARK: - Rate Limit Settings

public struct RateLimitSettings {
    public let enabled: Bool
    public let maxRequestsPerMinute: Int
    public let maxRequestsPerHour: Int
    public let maxRequestsPerDay: Int
    public let backoffStrategy: BackoffStrategy
    
    public init(
        enabled: Bool = true,
        maxRequestsPerMinute: Int = 20,
        maxRequestsPerHour: Int = 500,
        maxRequestsPerDay: Int = 2000,
        backoffStrategy: BackoffStrategy = .exponential
    ) {
        self.enabled = enabled
        self.maxRequestsPerMinute = maxRequestsPerMinute
        self.maxRequestsPerHour = maxRequestsPerHour
        self.maxRequestsPerDay = maxRequestsPerDay
        self.backoffStrategy = backoffStrategy
    }
    
    public static let `default` = RateLimitSettings()
    
    public static let generous = RateLimitSettings(
        enabled: true,
        maxRequestsPerMinute: 60,
        maxRequestsPerHour: 1000,
        maxRequestsPerDay: 5000,
        backoffStrategy: .linear
    )
    
    public static let conservative = RateLimitSettings(
        enabled: true,
        maxRequestsPerMinute: 5,
        maxRequestsPerHour: 100,
        maxRequestsPerDay: 500,
        backoffStrategy: .exponential
    )
    
    public static let disabled = RateLimitSettings(
        enabled: false,
        maxRequestsPerMinute: Int.max,
        maxRequestsPerHour: Int.max,
        maxRequestsPerDay: Int.max,
        backoffStrategy: .none
    )
}

// MARK: - Local Processing Settings

public struct LocalProcessingSettings {
    public let preferLocal: Bool
    public let fallbackToCloud: Bool
    public let maxLocalProcessingTime: TimeInterval
    public let enableGPUAcceleration: Bool
    public let modelOptimization: ModelOptimization
    
    public init(
        preferLocal: Bool = false,
        fallbackToCloud: Bool = true,
        maxLocalProcessingTime: TimeInterval = 60.0,
        enableGPUAcceleration: Bool = true,
        modelOptimization: ModelOptimization = .balanced
    ) {
        self.preferLocal = preferLocal
        self.fallbackToCloud = fallbackToCloud
        self.maxLocalProcessingTime = maxLocalProcessingTime
        self.enableGPUAcceleration = enableGPUAcceleration
        self.modelOptimization = modelOptimization
    }
    
    public static let `default` = LocalProcessingSettings()
    
    public static let localFirst = LocalProcessingSettings(
        preferLocal: true,
        fallbackToCloud: true,
        maxLocalProcessingTime: 120.0,
        enableGPUAcceleration: true,
        modelOptimization: .performance
    )
    
    public static let cloudOnly = LocalProcessingSettings(
        preferLocal: false,
        fallbackToCloud: false,
        maxLocalProcessingTime: 0.0,
        enableGPUAcceleration: false,
        modelOptimization: .none
    )
}

// MARK: - Security Settings

public struct SecuritySettings {
    public let enableContentFiltering: Bool
    public let enablePromptValidation: Bool
    public let maxPromptLength: Int
    public let allowExternalURLs: Bool
    public let encryptCachedImages: Bool
    public let logLevel: LogLevel
    
    public init(
        enableContentFiltering: Bool = true,
        enablePromptValidation: Bool = true,
        maxPromptLength: Int = 2000,
        allowExternalURLs: Bool = false,
        encryptCachedImages: Bool = true,
        logLevel: LogLevel = .info
    ) {
        self.enableContentFiltering = enableContentFiltering
        self.enablePromptValidation = enablePromptValidation
        self.maxPromptLength = maxPromptLength
        self.allowExternalURLs = allowExternalURLs
        self.encryptCachedImages = encryptCachedImages
        self.logLevel = logLevel
    }
    
    public static let `default` = SecuritySettings()
    
    public static let strict = SecuritySettings(
        enableContentFiltering: true,
        enablePromptValidation: true,
        maxPromptLength: 1000,
        allowExternalURLs: false,
        encryptCachedImages: true,
        logLevel: .warning
    )
    
    public static let relaxed = SecuritySettings(
        enableContentFiltering: false,
        enablePromptValidation: false,
        maxPromptLength: 5000,
        allowExternalURLs: true,
        encryptCachedImages: false,
        logLevel: .debug
    )
}

// MARK: - Enums

public enum ImageProvider: String, CaseIterable {
    case openai = "openai"
    case midjourney = "midjourney"
    case stabilityAI = "stability"
    case local = "local"
    
    public var displayName: String {
        switch self {
        case .openai: return "OpenAI DALL-E"
        case .midjourney: return "Midjourney"
        case .stabilityAI: return "Stability AI"
        case .local: return "Local Generation"
        }
    }
}

public enum BackoffStrategy: String, CaseIterable {
    case none = "none"
    case linear = "linear"
    case exponential = "exponential"
    case fibonacci = "fibonacci"
}

public enum ModelOptimization: String, CaseIterable {
    case none = "none"
    case memory = "memory"
    case performance = "performance"
    case balanced = "balanced"
}

public enum LogLevel: String, CaseIterable {
    case debug = "debug"
    case info = "info"
    case warning = "warning"
    case error = "error"
    case critical = "critical"
}

// MARK: - Predefined Configurations

public extension ImageGenerationEngineConfiguration {
    
    /// Development configuration with relaxed settings
    static func development(
        openAIKey: String? = nil,
        midjourneyKey: String? = nil,
        stabilityKey: String? = nil
    ) -> ImageGenerationEngineConfiguration {
        let providers = ProviderConfigurations(
            openAI: openAIKey.map { OpenAIImageConfiguration(apiKey: $0) },
            midjourney: midjourneyKey.map { MidjourneyConfiguration(apiKey: $0) },
            stabilityAI: stabilityKey.map { StabilityAIConfiguration(apiKey: $0) }
        )
        
        return ImageGenerationEngineConfiguration(
            providers: providers,
            defaultProvider: .local,
            performance: .default,
            quality: .fast,
            caching: .aggressive,
            rateLimiting: .generous,
            localProcessing: .localFirst,
            security: .relaxed
        )
    }
    
    /// Production configuration with optimal settings
    static func production(
        openAIKey: String,
        midjourneyKey: String? = nil,
        stabilityKey: String? = nil,
        encryptionKey: String? = nil
    ) -> ImageGenerationEngineConfiguration {
        let providers = ProviderConfigurations(
            openAI: OpenAIImageConfiguration(apiKey: openAIKey),
            midjourney: midjourneyKey.map { MidjourneyConfiguration(apiKey: $0) },
            stabilityAI: stabilityKey.map { StabilityAIConfiguration(apiKey: $0) }
        )
        
        return ImageGenerationEngineConfiguration(
            providers: providers,
            defaultProvider: .openai,
            performance: .highPerformance,
            quality: .highQuality,
            caching: .default,
            rateLimiting: .default,
            localProcessing: .default,
            security: .strict
        )
    }
    
    /// Privacy-focused configuration with local processing
    static func privacy(localModelsPath: String? = nil) -> ImageGenerationEngineConfiguration {
        let providers = ProviderConfigurations(
            local: LocalImageConfiguration(modelPath: localModelsPath)
        )
        
        return ImageGenerationEngineConfiguration(
            providers: providers,
            defaultProvider: .local,
            performance: .conservative,
            quality: .balanced,
            caching: .minimal,
            rateLimiting: .disabled,
            localProcessing: .localFirst,
            security: .strict
        )
    }
    
    /// Budget-conscious configuration
    static func budget(
        openAIKey: String? = nil,
        stabilityKey: String? = nil
    ) -> ImageGenerationEngineConfiguration {
        let providers = ProviderConfigurations(
            openAI: openAIKey.map { OpenAIImageConfiguration(apiKey: $0) },
            stabilityAI: stabilityKey.map { StabilityAIConfiguration(apiKey: $0) }
        )
        
        return ImageGenerationEngineConfiguration(
            providers: providers,
            defaultProvider: .local,
            performance: .conservative,
            quality: .fast,
            caching: .aggressive,
            rateLimiting: .conservative,
            localProcessing: .localFirst,
            security: .default
        )
    }
    
    /// Enterprise configuration with all providers
    static func enterprise(
        openAIKey: String,
        midjourneyKey: String,
        stabilityKey: String,
        encryptionKey: String
    ) -> ImageGenerationEngineConfiguration {
        let providers = ProviderConfigurations(
            openAI: OpenAIImageConfiguration(apiKey: openAIKey),
            midjourney: MidjourneyConfiguration(apiKey: midjourneyKey),
            stabilityAI: StabilityAIConfiguration(apiKey: stabilityKey),
            local: LocalImageConfiguration()
        )
        
        return ImageGenerationEngineConfiguration(
            providers: providers,
            defaultProvider: .openai,
            performance: .highPerformance,
            quality: .highQuality,
            caching: .aggressive,
            rateLimiting: .generous,
            localProcessing: .default,
            security: SecuritySettings(
                enableContentFiltering: true,
                enablePromptValidation: true,
                maxPromptLength: 3000,
                allowExternalURLs: true,
                encryptCachedImages: true,
                logLevel: .info
            )
        )
    }
}

// MARK: - Configuration Validation

public extension ImageGenerationEngineConfiguration {
    
    func validate() throws {
        // Validate at least one provider is configured
        guard providers.openAI != nil || providers.midjourney != nil || 
              providers.stabilityAI != nil || providers.local.enableTextToImage else {
            throw ConfigurationError.noProvidersConfigured
        }
        
        // Validate default provider is available
        switch defaultProvider {
        case .openai:
            guard providers.openAI != nil else {
                throw ConfigurationError.defaultProviderNotConfigured(defaultProvider)
            }
        case .midjourney:
            guard providers.midjourney != nil else {
                throw ConfigurationError.defaultProviderNotConfigured(defaultProvider)
            }
        case .stabilityAI:
            guard providers.stabilityAI != nil else {
                throw ConfigurationError.defaultProviderNotConfigured(defaultProvider)
            }
        case .local:
            guard providers.local.enableTextToImage else {
                throw ConfigurationError.defaultProviderNotConfigured(defaultProvider)
            }
        }
        
        // Validate performance settings
        guard performance.maxConcurrentRequests > 0 else {
            throw ConfigurationError.invalidPerformanceSettings("maxConcurrentRequests must be > 0")
        }
        
        guard performance.requestTimeout > 0 else {
            throw ConfigurationError.invalidPerformanceSettings("requestTimeout must be > 0")
        }
        
        // Validate cache settings
        if caching.enableImageCache || caching.enableResultCache {
            guard caching.maxCacheSize > 0 else {
                throw ConfigurationError.invalidCacheSettings("maxCacheSize must be > 0 when caching is enabled")
            }
        }
        
        // Validate security settings
        guard security.maxPromptLength > 0 else {
            throw ConfigurationError.invalidSecuritySettings("maxPromptLength must be > 0")
        }
    }
}

// MARK: - Configuration Errors

public enum ConfigurationError: LocalizedError {
    case noProvidersConfigured
    case defaultProviderNotConfigured(ImageProvider)
    case invalidPerformanceSettings(String)
    case invalidCacheSettings(String)
    case invalidSecuritySettings(String)
    
    public var errorDescription: String? {
        switch self {
        case .noProvidersConfigured:
            return "No image generation providers are configured"
        case .defaultProviderNotConfigured(let provider):
            return "Default provider '\(provider.displayName)' is not configured"
        case .invalidPerformanceSettings(let message):
            return "Invalid performance settings: \(message)"
        case .invalidCacheSettings(let message):
            return "Invalid cache settings: \(message)"
        case .invalidSecuritySettings(let message):
            return "Invalid security settings: \(message)"
        }
    }
}