import Foundation
import SwiftIntelligenceCore

#if canImport(Compression)
import Compression
#endif

/// Cache Engine - Intelligent caching system with memory and disk storage capabilities
public actor SwiftIntelligenceCache {
    
    // MARK: - Properties
    
    public let moduleID = "Cache"
    public let version = "1.0.0"
    public private(set) var status: ModuleStatus = .uninitialized
    
    // MARK: - Cache Components
    
    private var memoryCache: MemoryCache
    private var diskCache: DiskCache
    private var cacheStrategy: CacheStrategy = .hybrid
    private var evictionPolicy: EvictionPolicy = .lru
    private var compressionEnabled: Bool = true
    private var encryptionEnabled: Bool = false
    
    // MARK: - Configuration
    
    private var cacheConfiguration: CacheConfiguration = .default
    private let maxMemoryCacheSize: Int = 100 * 1024 * 1024 // 100MB
    private let maxDiskCacheSize: Int = 500 * 1024 * 1024   // 500MB
    private let defaultTTL: TimeInterval = 3600 // 1 hour
    
    // MARK: - Performance Monitoring
    
    private var performanceMetrics: CachePerformanceMetrics = CachePerformanceMetrics()
    nonisolated private let logger = IntelligenceLogger()
    
    // MARK: - Background Tasks
    
    private var cleanupTimer: Timer?
    private let cleanupInterval: TimeInterval = 300 // 5 minutes
    
    // MARK: - Initialization
    
    public init(configuration: CacheConfiguration = .default) async throws {
        self.cacheConfiguration = configuration
        self.memoryCache = MemoryCache(maxSize: configuration.maxMemorySize)
        self.diskCache = DiskCache(maxSize: configuration.maxDiskSize, baseURL: configuration.diskCacheURL)
        try await initializeCacheEngine()
    }
    
    private func initializeCacheEngine() async throws {
        status = .initializing
        logger.info("Initializing Cache Engine...", category: "Cache")
        
        // Setup cache components
        await setupCacheCapabilities()
        await validateCacheFrameworks()
        await startBackgroundTasks()
        
        status = .ready
        logger.info("Cache Engine initialized successfully", category: "Cache")
    }
    
    private func setupCacheCapabilities() async {
        logger.debug("Setting up Cache capabilities", category: "Cache")
        
        // Configure cache strategy
        cacheStrategy = cacheConfiguration.strategy
        evictionPolicy = cacheConfiguration.evictionPolicy
        compressionEnabled = cacheConfiguration.enableCompression
        encryptionEnabled = cacheConfiguration.enableEncryption
        
        // Initialize performance metrics
        performanceMetrics = CachePerformanceMetrics()
        
        logger.debug("Cache capabilities configured", category: "Cache")
    }
    
    private func validateCacheFrameworks() async {
        logger.debug("Validating Cache frameworks", category: "Cache")
        
        // Check compression framework availability
        #if canImport(Compression)
        logger.info("Compression framework available", category: "Cache")
        #else
        logger.warning("Compression framework not available", category: "Cache")
        compressionEnabled = false
        #endif
        
        // Validate disk cache directory
        let diskCacheValid = await diskCache.validateDirectory()
        if diskCacheValid {
            logger.info("Disk cache directory validated", category: "Cache")
        } else {
            logger.warning("Disk cache directory validation failed", category: "Cache")
        }
        
        // Validate memory cache
        let memoryCacheValid = await memoryCache.validate()
        if memoryCacheValid {
            logger.info("Memory cache validated", category: "Cache")
        } else {
            logger.warning("Memory cache validation failed", category: "Cache")
        }
    }
    
    private func startBackgroundTasks() async {
        logger.debug("Starting cache background tasks", category: "Cache")
        
        // Start cleanup timer
        await scheduleCleanupTask()
        
        logger.debug("Background tasks started", category: "Cache")
    }
    
    private func scheduleCleanupTask() async {
        // Schedule periodic cleanup
        Task { [weak self] in
            while await self?.status == .ready {
                try await Task.sleep(for: .seconds(300)) // 5 minutes
                await self?.performCleanup()
            }
        }
    }
    
    // MARK: - Core Cache Operations
    
    /// Get cached value
    public func get<T: Codable & Sendable>(_ key: String, as type: T.Type) async throws -> T? {
        guard status == .ready else {
            throw IntelligenceError(code: "CACHE_NOT_READY", message: "Cache Engine not ready")
        }
        
        let startTime = Date()
        logger.debug("Getting cached value for key: \(key)", category: "Cache")
        
        var result: T?
        var cacheHit = false
        var cacheLevel: CacheLevel = .none
        
        // Try memory cache first
        if let memoryResult = await memoryCache.get(key, as: type) {
            result = memoryResult
            cacheHit = true
            cacheLevel = .memory
            logger.debug("Cache hit in memory for key: \(key)", category: "Cache")
        }
        // Try disk cache if memory cache miss
        else if cacheStrategy == .hybrid || cacheStrategy == .diskOnly {
            if let diskResult = await diskCache.get(key, as: type) {
                result = diskResult
                cacheHit = true
                cacheLevel = .disk
                
                // Promote to memory cache if using hybrid strategy
                if cacheStrategy == .hybrid {
                    await memoryCache.set(key, value: diskResult, ttl: nil)
                }
                
                logger.debug("Cache hit in disk for key: \(key)", category: "Cache")
            }
        }
        
        let duration = Date().timeIntervalSince(startTime)
        await updateCacheMetrics(operation: .get, hit: cacheHit, level: cacheLevel, duration: duration)
        
        if result == nil {
            logger.debug("Cache miss for key: \(key)", category: "Cache")
        }
        
        return result
    }
    
    /// Set cached value
    public func set<T: Codable & Sendable>(_ key: String, value: T, ttl: TimeInterval? = nil) async throws {
        guard status == .ready else {
            throw IntelligenceError(code: "CACHE_NOT_READY", message: "Cache Engine not ready")
        }
        
        let startTime = Date()
        logger.debug("Setting cached value for key: \(key)", category: "Cache")
        
        let effectiveTTL = ttl ?? defaultTTL
        
        // Store according to cache strategy
        switch cacheStrategy {
        case .memoryOnly:
            await memoryCache.set(key, value: value, ttl: effectiveTTL)
        case .diskOnly:
            await diskCache.set(key, value: value, ttl: effectiveTTL)
        case .hybrid:
            await memoryCache.set(key, value: value, ttl: effectiveTTL)
            await diskCache.set(key, value: value, ttl: effectiveTTL)
        }
        
        let duration = Date().timeIntervalSince(startTime)
        await updateCacheMetrics(operation: .set, hit: false, level: .none, duration: duration)
        
        logger.debug("Cached value set for key: \(key)", category: "Cache")
    }
    
    /// Delete cached value
    public func delete(_ key: String) async throws {
        guard status == .ready else {
            throw IntelligenceError(code: "CACHE_NOT_READY", message: "Cache Engine not ready")
        }
        
        let startTime = Date()
        logger.debug("Deleting cached value for key: \(key)", category: "Cache")
        
        // Delete from all cache levels
        await memoryCache.delete(key)
        await diskCache.delete(key)
        
        let duration = Date().timeIntervalSince(startTime)
        await updateCacheMetrics(operation: .delete, hit: false, level: .none, duration: duration)
        
        logger.debug("Cached value deleted for key: \(key)", category: "Cache")
    }
    
    /// Check if key exists in cache
    public func exists(_ key: String) async -> Bool {
        let memoryExists = await memoryCache.exists(key)
        if memoryExists { return true }
        
        let diskExists = await diskCache.exists(key)
        return diskExists
    }
    
    // MARK: - Batch Operations
    
    /// Get multiple cached values
    public func getMultiple<T: Codable & Sendable>(_ keys: [String], as type: T.Type) async throws -> [String: T] {
        var results: [String: T] = [:]
        
        for key in keys {
            if let value = try await get(key, as: type) {
                results[key] = value
            }
        }
        
        return results
    }
    
    /// Set multiple cached values
    public func setMultiple<T: Codable & Sendable>(_ values: [String: T], ttl: TimeInterval? = nil) async throws {
        for (key, value) in values {
            try await set(key, value: value, ttl: ttl)
        }
    }
    
    /// Delete multiple cached values
    public func deleteMultiple(_ keys: [String]) async throws {
        for key in keys {
            try await delete(key)
        }
    }
    
    // MARK: - Cache Management
    
    /// Clear all cached data
    public func clearAll() async {
        logger.info("Clearing all cached data", category: "Cache")
        
        await memoryCache.clearAll()
        await diskCache.clearAll()
        
        performanceMetrics.cacheClearOperations += 1
        
        logger.info("All cached data cleared", category: "Cache")
    }
    
    /// Clear expired entries
    public func clearExpired() async {
        logger.debug("Clearing expired cache entries", category: "Cache")
        
        let expiredMemoryKeys = await memoryCache.clearExpired()
        let expiredDiskKeys = await diskCache.clearExpired()
        
        performanceMetrics.expiredEntriesCleared += expiredMemoryKeys + expiredDiskKeys
        
        logger.debug("Cleared \(expiredMemoryKeys + expiredDiskKeys) expired entries", category: "Cache")
    }
    
    /// Perform cache cleanup
    private func performCleanup() async {
        logger.debug("Performing cache cleanup", category: "Cache")
        
        // Clear expired entries
        await clearExpired()
        
        // Apply eviction policy if cache is full
        await applyEvictionPolicy()
        
        // Update cleanup metrics
        performanceMetrics.cleanupOperations += 1
        
        logger.debug("Cache cleanup completed", category: "Cache")
    }
    
    /// Apply eviction policy
    private func applyEvictionPolicy() async {
        let memoryUsage = await memoryCache.getCurrentSize()
        let diskUsage = await diskCache.getCurrentSize()
        
        // Apply memory cache eviction
        if memoryUsage > maxMemoryCacheSize {
            let keysToEvict = await memoryCache.getKeysForEviction(policy: evictionPolicy)
            for key in keysToEvict {
                await memoryCache.delete(key)
                performanceMetrics.evictedEntries += 1
            }
        }
        
        // Apply disk cache eviction
        if diskUsage > maxDiskCacheSize {
            let keysToEvict = await diskCache.getKeysForEviction(policy: evictionPolicy)
            for key in keysToEvict {
                await diskCache.delete(key)
                performanceMetrics.evictedEntries += 1
            }
        }
    }
    
    // MARK: - Cache Warming
    
    /// Warm cache with frequently accessed data
    public func warmCache<T: Codable & Sendable>(with data: [String: T]) async {
        logger.info("Warming cache with \(data.count) entries", category: "Cache")
        
        for (key, value) in data {
            try? await set(key, value: value)
        }
        
        performanceMetrics.cacheWarmingOperations += 1
        
        logger.info("Cache warming completed", category: "Cache")
    }
    
    // MARK: - Statistics and Health
    
    /// Get cache statistics
    public func getStatistics() async -> CacheStatistics {
        let memoryStats = await memoryCache.getStatistics()
        let diskStats = await diskCache.getStatistics()
        
        return CacheStatistics(
            totalHits: performanceMetrics.hits,
            totalMisses: performanceMetrics.misses,
            hitRate: performanceMetrics.totalRequests > 0 
                ? Float(performanceMetrics.hits) / Float(performanceMetrics.totalRequests) 
                : 0.0,
            memorySize: memoryStats.memorySize,
            diskSize: diskStats.diskSize,
            totalSize: memoryStats.memorySize + diskStats.diskSize,
            entryCount: memoryStats.entryCount + diskStats.entryCount,
            evictedEntries: performanceMetrics.evictedEntries,
            expiredEntries: performanceMetrics.expiredEntriesCleared
        )
    }
    
    /// Get cache health information
    public func getCacheHealth() async -> CacheHealth {
        let memoryUsage = Float(await memoryCache.getCurrentSize()) / Float(maxMemoryCacheSize)
        let diskUsage = Float(await diskCache.getCurrentSize()) / Float(maxDiskCacheSize)
        
        let healthScore: Float
        let hitRate = performanceMetrics.totalRequests > 0 
            ? Float(performanceMetrics.hits) / Float(performanceMetrics.totalRequests) 
            : 0.0
        
        // Calculate health score based on hit rate and usage
        healthScore = (hitRate * 0.6) + ((1.0 - max(memoryUsage, diskUsage)) * 0.4)
        
        return CacheHealth(
            healthScore: healthScore,
            memoryUsage: memoryUsage,
            diskUsage: diskUsage,
            hitRate: hitRate,
            isHealthy: healthScore > 0.7,
            recommendations: generateHealthRecommendations(healthScore: healthScore, memoryUsage: memoryUsage, diskUsage: diskUsage)
        )
    }
    
    private func generateHealthRecommendations(healthScore: Float, memoryUsage: Float, diskUsage: Float) -> [String] {
        var recommendations: [String] = []
        
        if healthScore < 0.5 {
            recommendations.append("Cache performance is poor. Consider optimizing cache strategy.")
        }
        
        if memoryUsage > 0.8 {
            recommendations.append("Memory cache usage is high. Consider increasing memory limit or enabling more aggressive eviction.")
        }
        
        if diskUsage > 0.8 {
            recommendations.append("Disk cache usage is high. Consider cleaning up old entries or increasing disk limit.")
        }
        
        if performanceMetrics.totalRequests > 0 && Float(performanceMetrics.hits) / Float(performanceMetrics.totalRequests) < 0.5 {
            recommendations.append("Hit rate is low. Consider adjusting TTL values or cache warming strategy.")
        }
        
        return recommendations
    }
    
    // MARK: - Performance Metrics
    
    private func updateCacheMetrics(operation: CacheOperation, hit: Bool, level: CacheLevel, duration: TimeInterval) async {
        performanceMetrics.totalRequests += 1
        performanceMetrics.averageResponseTime = (performanceMetrics.averageResponseTime + duration) / 2.0
        
        switch operation {
        case .get:
            if hit {
                performanceMetrics.hits += 1
                switch level {
                case .memory:
                    performanceMetrics.memoryHits += 1
                case .disk:
                    performanceMetrics.diskHits += 1
                case .none:
                    break
                }
            } else {
                performanceMetrics.misses += 1
            }
        case .set:
            performanceMetrics.writes += 1
        case .delete:
            performanceMetrics.deletes += 1
        }
    }
    
    /// Get performance metrics
    public func getPerformanceMetrics() async -> CachePerformanceMetrics {
        return performanceMetrics
    }
    
    /// Update cache configuration
    public func updateConfiguration(_ configuration: CacheConfiguration) async {
        cacheConfiguration = configuration
        cacheStrategy = configuration.strategy
        evictionPolicy = configuration.evictionPolicy
        compressionEnabled = configuration.enableCompression
        encryptionEnabled = configuration.enableEncryption
        
        // Update cache components with new configuration
        await memoryCache.updateConfiguration(maxSize: configuration.maxMemorySize)
        await diskCache.updateConfiguration(maxSize: configuration.maxDiskSize)
        
        logger.info("Cache configuration updated", category: "Cache")
    }
}

// MARK: - IntelligenceProtocol Compliance

extension SwiftIntelligenceCache: IntelligenceProtocol {
    
    public func initialize() async throws {
        try await initializeCacheEngine()
    }
    
    public func shutdown() async throws {
        await clearAll()
        cleanupTimer?.invalidate()
        cleanupTimer = nil
        status = .shutdown
        logger.info("Cache Engine shutdown complete", category: "Cache")
    }
    
    public func validate() async throws -> ValidationResult {
        var errors: [ValidationError] = []
        var warnings: [ValidationWarning] = []
        
        if status != .ready {
            errors.append(ValidationError(code: "CACHE_NOT_READY", message: "Cache Engine not ready"))
        }
        
        let memoryValid = await memoryCache.validate()
        if !memoryValid {
            warnings.append(ValidationWarning(code: "MEMORY_CACHE_INVALID", message: "Memory cache validation failed"))
        }
        
        let diskValid = await diskCache.validateDirectory()
        if !diskValid {
            warnings.append(ValidationWarning(code: "DISK_CACHE_INVALID", message: "Disk cache validation failed"))
        }
        
        return ValidationResult(isValid: errors.isEmpty, errors: errors, warnings: warnings)
    }
    
    public func healthCheck() async -> HealthStatus {
        let cacheHealth = await getCacheHealth()
        let statistics = await getStatistics()
        
        let metrics = [
            "total_requests": String(performanceMetrics.totalRequests),
            "cache_hits": String(performanceMetrics.hits),
            "cache_misses": String(performanceMetrics.misses),
            "hit_rate": String(format: "%.2f", statistics.hitRate),
            "memory_usage": String(format: "%.2f", cacheHealth.memoryUsage),
            "disk_usage": String(format: "%.2f", cacheHealth.diskUsage),
            "total_entries": String(statistics.entryCount),
            "health_score": String(format: "%.2f", cacheHealth.healthScore)
        ]
        
        switch status {
        case .ready:
            let statusType: HealthStatus.HealthState = cacheHealth.isHealthy ? .healthy : .degraded
            let message = cacheHealth.isHealthy 
                ? "Cache Engine operational with \(performanceMetrics.totalRequests) requests processed"
                : "Cache Engine operational but performance degraded"
            
            return HealthStatus(status: statusType, message: message, metrics: metrics)
        case .error:
            return HealthStatus(
                status: .unhealthy,
                message: "Cache Engine encountered an error",
                metrics: metrics
            )
        default:
            return HealthStatus(
                status: .degraded,
                message: "Cache Engine not ready",
                metrics: metrics
            )
        }
    }
}

// MARK: - Supporting Enums

private enum CacheOperation {
    case get
    case set
    case delete
}

private enum CacheLevel {
    case memory
    case disk
    case none
}

// MARK: - Performance Metrics

/// Cache engine performance metrics
public struct CachePerformanceMetrics: Sendable {
    public var totalRequests: Int = 0
    public var hits: Int = 0
    public var misses: Int = 0
    public var memoryHits: Int = 0
    public var diskHits: Int = 0
    public var writes: Int = 0
    public var deletes: Int = 0
    public var evictedEntries: Int = 0
    public var expiredEntriesCleared: Int = 0
    public var cacheClearOperations: Int = 0
    public var cacheWarmingOperations: Int = 0
    public var cleanupOperations: Int = 0
    public var averageResponseTime: TimeInterval = 0.0
    
    public init() {}
}