import Foundation
import Network
import os.log

/// Advanced configuration system for LLM operations
public struct LLMEngineConfiguration {
    
    // MARK: - Provider Configurations
    public let providers: ProviderConfigurations
    public let defaultProvider: String
    public let fallbackProviders: [String]
    
    // MARK: - Model Settings
    public let modelSettings: ModelSettings
    
    // MARK: - Performance Settings
    public let performanceSettings: PerformanceSettings
    
    // MARK: - Security Settings
    public let securitySettings: SecuritySettings
    
    // MARK: - Monitoring Settings
    public let monitoringSettings: MonitoringSettings
    
    public struct ProviderConfigurations {
        public let openAI: OpenAIProviderConfig
        public let anthropic: AnthropicProviderConfig
        public let google: GoogleProviderConfig
        public let local: LocalProviderConfig
        
        public init(
            openAI: OpenAIProviderConfig,
            anthropic: AnthropicProviderConfig,
            google: GoogleProviderConfig,
            local: LocalProviderConfig
        ) {
            self.openAI = openAI
            self.anthropic = anthropic
            self.google = google
            self.local = local
        }
    }
    
    public struct OpenAIProviderConfig {
        public let enabled: Bool
        public let apiKey: String
        public let organizationID: String?
        public let baseURL: String
        public let defaultModel: String
        public let maxRetries: Int
        public let timeout: TimeInterval
        
        public init(
            enabled: Bool = true,
            apiKey: String,
            organizationID: String? = nil,
            baseURL: String = "https://api.openai.com/v1",
            defaultModel: String = "gpt-4",
            maxRetries: Int = 3,
            timeout: TimeInterval = 60
        ) {
            self.enabled = enabled
            self.apiKey = apiKey
            self.organizationID = organizationID
            self.baseURL = baseURL
            self.defaultModel = defaultModel
            self.maxRetries = maxRetries
            self.timeout = timeout
        }
    }
    
    public struct AnthropicProviderConfig {
        public let enabled: Bool
        public let apiKey: String
        public let baseURL: String
        public let defaultModel: String
        public let maxRetries: Int
        public let timeout: TimeInterval
        
        public init(
            enabled: Bool = true,
            apiKey: String,
            baseURL: String = "https://api.anthropic.com/v1",
            defaultModel: String = "claude-3-sonnet-20240229",
            maxRetries: Int = 3,
            timeout: TimeInterval = 60
        ) {
            self.enabled = enabled
            self.apiKey = apiKey
            self.baseURL = baseURL
            self.defaultModel = defaultModel
            self.maxRetries = maxRetries
            self.timeout = timeout
        }
    }
    
    public struct GoogleProviderConfig {
        public let enabled: Bool
        public let apiKey: String
        public let baseURL: String
        public let defaultModel: String
        public let maxRetries: Int
        public let timeout: TimeInterval
        
        public init(
            enabled: Bool = true,
            apiKey: String,
            baseURL: String = "https://generativelanguage.googleapis.com/v1",
            defaultModel: String = "gemini-pro",
            maxRetries: Int = 3,
            timeout: TimeInterval = 60
        ) {
            self.enabled = enabled
            self.apiKey = apiKey
            self.baseURL = baseURL
            self.defaultModel = defaultModel
            self.maxRetries = maxRetries
            self.timeout = timeout
        }
    }
    
    public struct LocalProviderConfig {
        public let enabled: Bool
        public let maxConcurrentRequests: Int
        public let modelCacheSize: Int
        public let preloadModels: [String]
        public let enableGPUAcceleration: Bool
        
        public init(
            enabled: Bool = true,
            maxConcurrentRequests: Int = 2,
            modelCacheSize: Int = 3,
            preloadModels: [String] = ["local-chat-small"],
            enableGPUAcceleration: Bool = true
        ) {
            self.enabled = enabled
            self.maxConcurrentRequests = maxConcurrentRequests
            self.modelCacheSize = modelCacheSize
            self.preloadModels = preloadModels
            self.enableGPUAcceleration = enableGPUAcceleration
        }
    }
    
    public struct ModelSettings {
        public let defaultChatModel: String
        public let defaultEmbeddingModel: String
        public let defaultImageModel: String
        public let modelAliases: [String: String]
        public let modelPriorities: [String: Int]
        
        public init(
            defaultChatModel: String = "gpt-4",
            defaultEmbeddingModel: String = "text-embedding-ada-002",
            defaultImageModel: String = "dall-e-3",
            modelAliases: [String: String] = [:],
            modelPriorities: [String: Int] = [:]
        ) {
            self.defaultChatModel = defaultChatModel
            self.defaultEmbeddingModel = defaultEmbeddingModel
            self.defaultImageModel = defaultImageModel
            self.modelAliases = modelAliases
            self.modelPriorities = modelPriorities
        }
    }
    
    public struct PerformanceSettings {
        public let maxConcurrentRequests: Int
        public let requestTimeout: TimeInterval
        public let connectionPoolSize: Int
        public let enableResponseCaching: Bool
        public let cacheSize: Int
        public let cacheTTL: TimeInterval
        public let enableRequestBatching: Bool
        public let batchSize: Int
        public let enableCompression: Bool
        
        public init(
            maxConcurrentRequests: Int = 10,
            requestTimeout: TimeInterval = 60,
            connectionPoolSize: Int = 5,
            enableResponseCaching: Bool = true,
            cacheSize: Int = 100,
            cacheTTL: TimeInterval = 3600,
            enableRequestBatching: Bool = false,
            batchSize: Int = 5,
            enableCompression: Bool = true
        ) {
            self.maxConcurrentRequests = maxConcurrentRequests
            self.requestTimeout = requestTimeout
            self.connectionPoolSize = connectionPoolSize
            self.enableResponseCaching = enableResponseCaching
            self.cacheSize = cacheSize
            self.cacheTTL = cacheTTL
            self.enableRequestBatching = enableRequestBatching
            self.batchSize = batchSize
            self.enableCompression = enableCompression
        }
    }
    
    public struct SecuritySettings {
        public let enableTLSVerification: Bool
        public let allowInsecureConnections: Bool
        public let enableAPIKeyRotation: Bool
        public let apiKeyRotationInterval: TimeInterval
        public let enableRequestSigning: Bool
        public let dataEncryptionKey: String?
        public let enableAuditLogging: Bool
        public let sanitizeInputs: Bool
        public let enableContentFiltering: Bool
        
        public init(
            enableTLSVerification: Bool = true,
            allowInsecureConnections: Bool = false,
            enableAPIKeyRotation: Bool = false,
            apiKeyRotationInterval: TimeInterval = 86400 * 30, // 30 days
            enableRequestSigning: Bool = false,
            dataEncryptionKey: String? = nil,
            enableAuditLogging: Bool = true,
            sanitizeInputs: Bool = true,
            enableContentFiltering: Bool = true
        ) {
            self.enableTLSVerification = enableTLSVerification
            self.allowInsecureConnections = allowInsecureConnections
            self.enableAPIKeyRotation = enableAPIKeyRotation
            self.apiKeyRotationInterval = apiKeyRotationInterval
            self.enableRequestSigning = enableRequestSigning
            self.dataEncryptionKey = dataEncryptionKey
            self.enableAuditLogging = enableAuditLogging
            self.sanitizeInputs = sanitizeInputs
            self.enableContentFiltering = enableContentFiltering
        }
    }
    
    public struct MonitoringSettings {
        public let enableMetrics: Bool
        public let enableHealthChecks: Bool
        public let healthCheckInterval: TimeInterval
        public let enableUsageTracking: Bool
        public let enablePerformanceMetrics: Bool
        public let enableErrorTracking: Bool
        public let metricsExportInterval: TimeInterval
        
        public init(
            enableMetrics: Bool = true,
            enableHealthChecks: Bool = true,
            healthCheckInterval: TimeInterval = 300, // 5 minutes
            enableUsageTracking: Bool = true,
            enablePerformanceMetrics: Bool = true,
            enableErrorTracking: Bool = true,
            metricsExportInterval: TimeInterval = 60 // 1 minute
        ) {
            self.enableMetrics = enableMetrics
            self.enableHealthChecks = enableHealthChecks
            self.healthCheckInterval = healthCheckInterval
            self.enableUsageTracking = enableUsageTracking
            self.enablePerformanceMetrics = enablePerformanceMetrics
            self.enableErrorTracking = enableErrorTracking
            self.metricsExportInterval = metricsExportInterval
        }
    }
    
    public init(
        providers: ProviderConfigurations,
        defaultProvider: String = "openai",
        fallbackProviders: [String] = ["anthropic", "google"],
        modelSettings: ModelSettings = ModelSettings(),
        performanceSettings: PerformanceSettings = PerformanceSettings(),
        securitySettings: SecuritySettings = SecuritySettings(),
        monitoringSettings: MonitoringSettings = MonitoringSettings()
    ) {
        self.providers = providers
        self.defaultProvider = defaultProvider
        self.fallbackProviders = fallbackProviders
        self.modelSettings = modelSettings
        self.performanceSettings = performanceSettings
        self.securitySettings = securitySettings
        self.monitoringSettings = monitoringSettings
    }
}

// MARK: - Predefined Configurations

extension LLMEngineConfiguration {
    
    /// Default configuration for development
    public static func development(
        openAIKey: String = "",
        anthropicKey: String = "",
        googleKey: String = ""
    ) -> LLMEngineConfiguration {
        return LLMEngineConfiguration(
            providers: ProviderConfigurations(
                openAI: OpenAIProviderConfig(apiKey: openAIKey, defaultModel: "gpt-3.5-turbo"),
                anthropic: AnthropicProviderConfig(apiKey: anthropicKey),
                google: GoogleProviderConfig(apiKey: googleKey),
                local: LocalProviderConfig(enabled: true, preloadModels: [])
            ),
            performanceSettings: PerformanceSettings(
                maxConcurrentRequests: 3,
                enableResponseCaching: false,
                enableRequestBatching: false
            ),
            securitySettings: SecuritySettings(
                enableAuditLogging: false,
                enableContentFiltering: false
            )
        )
    }
    
    /// Production configuration with enhanced security and monitoring
    public static func production(
        openAIKey: String,
        anthropicKey: String,
        googleKey: String,
        encryptionKey: String? = nil
    ) -> LLMEngineConfiguration {
        return LLMEngineConfiguration(
            providers: ProviderConfigurations(
                openAI: OpenAIProviderConfig(
                    apiKey: openAIKey,
                    defaultModel: "gpt-4",
                    maxRetries: 5,
                    timeout: 120
                ),
                anthropic: AnthropicProviderConfig(
                    apiKey: anthropicKey,
                    maxRetries: 5,
                    timeout: 120
                ),
                google: GoogleProviderConfig(
                    apiKey: googleKey,
                    maxRetries: 5,
                    timeout: 120
                ),
                local: LocalProviderConfig(enabled: false)
            ),
            fallbackProviders: ["anthropic", "google", "openai"],
            performanceSettings: PerformanceSettings(
                maxConcurrentRequests: 20,
                requestTimeout: 120,
                connectionPoolSize: 10,
                enableResponseCaching: true,
                cacheSize: 1000,
                cacheTTL: 1800,
                enableRequestBatching: true,
                batchSize: 10
            ),
            securitySettings: SecuritySettings(
                enableTLSVerification: true,
                allowInsecureConnections: false,
                enableAPIKeyRotation: true,
                enableRequestSigning: true,
                dataEncryptionKey: encryptionKey,
                enableAuditLogging: true,
                sanitizeInputs: true,
                enableContentFiltering: true
            ),
            monitoringSettings: MonitoringSettings(
                enableMetrics: true,
                enableHealthChecks: true,
                healthCheckInterval: 60,
                enableUsageTracking: true,
                enablePerformanceMetrics: true,
                enableErrorTracking: true,
                metricsExportInterval: 30
            )
        )
    }
    
    /// Privacy-focused configuration with local processing
    public static func privacy(localModels: [String] = ["local-chat-small", "local-embedding"]) -> LLMEngineConfiguration {
        return LLMEngineConfiguration(
            providers: ProviderConfigurations(
                openAI: OpenAIProviderConfig(enabled: false, apiKey: ""),
                anthropic: AnthropicProviderConfig(enabled: false, apiKey: ""),
                google: GoogleProviderConfig(enabled: false, apiKey: ""),
                local: LocalProviderConfig(
                    enabled: true,
                    maxConcurrentRequests: 2,
                    modelCacheSize: 5,
                    preloadModels: localModels,
                    enableGPUAcceleration: true
                )
            ),
            defaultProvider: "local",
            fallbackProviders: [],
            performanceSettings: PerformanceSettings(
                maxConcurrentRequests: 2,
                enableResponseCaching: true,
                enableRequestBatching: false
            ),
            securitySettings: SecuritySettings(
                enableTLSVerification: true,
                allowInsecureConnections: false,
                enableAPIKeyRotation: false,
                enableRequestSigning: false,
                dataEncryptionKey: nil,
                enableAuditLogging: false,
                sanitizeInputs: true,
                enableContentFiltering: true
            ),
            monitoringSettings: MonitoringSettings(
                enableMetrics: false,
                enableHealthChecks: false,
                enableUsageTracking: false,
                enablePerformanceMetrics: false,
                enableErrorTracking: false
            )
        )
    }
    
    /// High-performance configuration for enterprise use
    public static func enterprise(
        openAIKey: String,
        anthropicKey: String,
        googleKey: String,
        encryptionKey: String
    ) -> LLMEngineConfiguration {
        return LLMEngineConfiguration(
            providers: ProviderConfigurations(
                openAI: OpenAIProviderConfig(
                    apiKey: openAIKey,
                    defaultModel: "gpt-4-turbo",
                    maxRetries: 5,
                    timeout: 180
                ),
                anthropic: AnthropicProviderConfig(
                    apiKey: anthropicKey,
                    defaultModel: "claude-3-opus-20240229",
                    maxRetries: 5,
                    timeout: 180
                ),
                google: GoogleProviderConfig(
                    apiKey: googleKey,
                    defaultModel: "gemini-pro",
                    maxRetries: 5,
                    timeout: 180
                ),
                local: LocalProviderConfig(
                    enabled: true,
                    maxConcurrentRequests: 5,
                    modelCacheSize: 10,
                    preloadModels: ["local-chat-medium", "local-embedding"],
                    enableGPUAcceleration: true
                )
            ),
            fallbackProviders: ["anthropic", "google", "local"],
            modelSettings: ModelSettings(
                defaultChatModel: "gpt-4-turbo",
                defaultEmbeddingModel: "text-embedding-ada-002",
                defaultImageModel: "dall-e-3",
                modelAliases: [
                    "gpt4": "gpt-4-turbo",
                    "claude": "claude-3-opus-20240229",
                    "gemini": "gemini-pro"
                ]
            ),
            performanceSettings: PerformanceSettings(
                maxConcurrentRequests: 50,
                requestTimeout: 180,
                connectionPoolSize: 20,
                enableResponseCaching: true,
                cacheSize: 5000,
                cacheTTL: 3600,
                enableRequestBatching: true,
                batchSize: 20,
                enableCompression: true
            ),
            securitySettings: SecuritySettings(
                enableTLSVerification: true,
                allowInsecureConnections: false,
                enableAPIKeyRotation: true,
                apiKeyRotationInterval: 86400 * 7, // 7 days
                enableRequestSigning: true,
                dataEncryptionKey: encryptionKey,
                enableAuditLogging: true,
                sanitizeInputs: true,
                enableContentFiltering: true
            ),
            monitoringSettings: MonitoringSettings(
                enableMetrics: true,
                enableHealthChecks: true,
                healthCheckInterval: 30,
                enableUsageTracking: true,
                enablePerformanceMetrics: true,
                enableErrorTracking: true,
                metricsExportInterval: 15
            )
        )
    }
}

// MARK: - Configuration Builder

public class LLMConfigurationBuilder {
    private var config: LLMEngineConfiguration
    
    public init() {
        self.config = LLMEngineConfiguration.development()
    }
    
    public init(from baseConfig: LLMEngineConfiguration) {
        self.config = baseConfig
    }
    
    // MARK: - Provider Configuration
    
    public func setOpenAI(
        enabled: Bool = true,
        apiKey: String,
        organizationID: String? = nil,
        baseURL: String = "https://api.openai.com/v1",
        defaultModel: String = "gpt-4"
    ) -> Self {
        let openAIConfig = LLMEngineConfiguration.OpenAIProviderConfig(
            enabled: enabled,
            apiKey: apiKey,
            organizationID: organizationID,
            baseURL: baseURL,
            defaultModel: defaultModel
        )
        
        config = LLMEngineConfiguration(
            providers: LLMEngineConfiguration.ProviderConfigurations(
                openAI: openAIConfig,
                anthropic: config.providers.anthropic,
                google: config.providers.google,
                local: config.providers.local
            ),
            defaultProvider: config.defaultProvider,
            fallbackProviders: config.fallbackProviders,
            modelSettings: config.modelSettings,
            performanceSettings: config.performanceSettings,
            securitySettings: config.securitySettings,
            monitoringSettings: config.monitoringSettings
        )
        
        return self
    }
    
    public func setAnthropic(
        enabled: Bool = true,
        apiKey: String,
        baseURL: String = "https://api.anthropic.com/v1",
        defaultModel: String = "claude-3-sonnet-20240229"
    ) -> Self {
        let anthropicConfig = LLMEngineConfiguration.AnthropicProviderConfig(
            enabled: enabled,
            apiKey: apiKey,
            baseURL: baseURL,
            defaultModel: defaultModel
        )
        
        config = LLMEngineConfiguration(
            providers: LLMEngineConfiguration.ProviderConfigurations(
                openAI: config.providers.openAI,
                anthropic: anthropicConfig,
                google: config.providers.google,
                local: config.providers.local
            ),
            defaultProvider: config.defaultProvider,
            fallbackProviders: config.fallbackProviders,
            modelSettings: config.modelSettings,
            performanceSettings: config.performanceSettings,
            securitySettings: config.securitySettings,
            monitoringSettings: config.monitoringSettings
        )
        
        return self
    }
    
    public func setGoogle(
        enabled: Bool = true,
        apiKey: String,
        baseURL: String = "https://generativelanguage.googleapis.com/v1",
        defaultModel: String = "gemini-pro"
    ) -> Self {
        let googleConfig = LLMEngineConfiguration.GoogleProviderConfig(
            enabled: enabled,
            apiKey: apiKey,
            baseURL: baseURL,
            defaultModel: defaultModel
        )
        
        config = LLMEngineConfiguration(
            providers: LLMEngineConfiguration.ProviderConfigurations(
                openAI: config.providers.openAI,
                anthropic: config.providers.anthropic,
                google: googleConfig,
                local: config.providers.local
            ),
            defaultProvider: config.defaultProvider,
            fallbackProviders: config.fallbackProviders,
            modelSettings: config.modelSettings,
            performanceSettings: config.performanceSettings,
            securitySettings: config.securitySettings,
            monitoringSettings: config.monitoringSettings
        )
        
        return self
    }
    
    // MARK: - Settings Configuration
    
    public func setDefaultProvider(_ provider: String) -> Self {
        config = LLMEngineConfiguration(
            providers: config.providers,
            defaultProvider: provider,
            fallbackProviders: config.fallbackProviders,
            modelSettings: config.modelSettings,
            performanceSettings: config.performanceSettings,
            securitySettings: config.securitySettings,
            monitoringSettings: config.monitoringSettings
        )
        
        return self
    }
    
    public func setFallbackProviders(_ providers: [String]) -> Self {
        config = LLMEngineConfiguration(
            providers: config.providers,
            defaultProvider: config.defaultProvider,
            fallbackProviders: providers,
            modelSettings: config.modelSettings,
            performanceSettings: config.performanceSettings,
            securitySettings: config.securitySettings,
            monitoringSettings: config.monitoringSettings
        )
        
        return self
    }
    
    public func enableCaching(_ enabled: Bool, size: Int = 100, ttl: TimeInterval = 3600) -> Self {
        let performanceSettings = LLMEngineConfiguration.PerformanceSettings(
            maxConcurrentRequests: config.performanceSettings.maxConcurrentRequests,
            requestTimeout: config.performanceSettings.requestTimeout,
            connectionPoolSize: config.performanceSettings.connectionPoolSize,
            enableResponseCaching: enabled,
            cacheSize: size,
            cacheTTL: ttl,
            enableRequestBatching: config.performanceSettings.enableRequestBatching,
            batchSize: config.performanceSettings.batchSize,
            enableCompression: config.performanceSettings.enableCompression
        )
        
        config = LLMEngineConfiguration(
            providers: config.providers,
            defaultProvider: config.defaultProvider,
            fallbackProviders: config.fallbackProviders,
            modelSettings: config.modelSettings,
            performanceSettings: performanceSettings,
            securitySettings: config.securitySettings,
            monitoringSettings: config.monitoringSettings
        )
        
        return self
    }
    
    public func enableSecurity(
        encryptionKey: String? = nil,
        enableAuditLogging: Bool = true,
        enableContentFiltering: Bool = true
    ) -> Self {
        let securitySettings = LLMEngineConfiguration.SecuritySettings(
            enableTLSVerification: config.securitySettings.enableTLSVerification,
            allowInsecureConnections: config.securitySettings.allowInsecureConnections,
            enableAPIKeyRotation: config.securitySettings.enableAPIKeyRotation,
            apiKeyRotationInterval: config.securitySettings.apiKeyRotationInterval,
            enableRequestSigning: config.securitySettings.enableRequestSigning,
            dataEncryptionKey: encryptionKey,
            enableAuditLogging: enableAuditLogging,
            sanitizeInputs: config.securitySettings.sanitizeInputs,
            enableContentFiltering: enableContentFiltering
        )
        
        config = LLMEngineConfiguration(
            providers: config.providers,
            defaultProvider: config.defaultProvider,
            fallbackProviders: config.fallbackProviders,
            modelSettings: config.modelSettings,
            performanceSettings: config.performanceSettings,
            securitySettings: securitySettings,
            monitoringSettings: config.monitoringSettings
        )
        
        return self
    }
    
    public func build() -> LLMEngineConfiguration {
        return config
    }
}

// MARK: - Configuration Validation

extension LLMEngineConfiguration {
    
    /// Validate the configuration and return any issues
    public func validate() -> [ConfigurationIssue] {
        var issues: [ConfigurationIssue] = []
        
        // Validate provider configurations
        if providers.openAI.enabled && providers.openAI.apiKey.isEmpty {
            issues.append(.missingAPIKey("OpenAI"))
        }
        
        if providers.anthropic.enabled && providers.anthropic.apiKey.isEmpty {
            issues.append(.missingAPIKey("Anthropic"))
        }
        
        if providers.google.enabled && providers.google.apiKey.isEmpty {
            issues.append(.missingAPIKey("Google"))
        }
        
        // Validate default provider
        let availableProviders = getEnabledProviders()
        if !availableProviders.contains(defaultProvider) {
            issues.append(.invalidDefaultProvider(defaultProvider))
        }
        
        // Validate performance settings
        if performanceSettings.maxConcurrentRequests <= 0 {
            issues.append(.invalidPerformanceSetting("maxConcurrentRequests must be > 0"))
        }
        
        if performanceSettings.requestTimeout <= 0 {
            issues.append(.invalidPerformanceSetting("requestTimeout must be > 0"))
        }
        
        // Validate security settings
        if securitySettings.enableAPIKeyRotation && securitySettings.apiKeyRotationInterval <= 0 {
            issues.append(.invalidSecuritySetting("apiKeyRotationInterval must be > 0 when rotation is enabled"))
        }
        
        return issues
    }
    
    private func getEnabledProviders() -> [String] {
        var enabled: [String] = []
        
        if providers.openAI.enabled { enabled.append("openai") }
        if providers.anthropic.enabled { enabled.append("anthropic") }
        if providers.google.enabled { enabled.append("google") }
        if providers.local.enabled { enabled.append("local") }
        
        return enabled
    }
}

public enum ConfigurationIssue {
    case missingAPIKey(String)
    case invalidDefaultProvider(String)
    case invalidPerformanceSetting(String)
    case invalidSecuritySetting(String)
    
    public var description: String {
        switch self {
        case .missingAPIKey(let provider):
            return "Missing API key for \(provider) provider"
        case .invalidDefaultProvider(let provider):
            return "Default provider '\(provider)' is not enabled or available"
        case .invalidPerformanceSetting(let setting):
            return "Invalid performance setting: \(setting)"
        case .invalidSecuritySetting(let setting):
            return "Invalid security setting: \(setting)"
        }
    }
}