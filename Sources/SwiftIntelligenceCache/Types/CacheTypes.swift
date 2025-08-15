import Foundation
import SwiftIntelligenceCore

// MARK: - Cache Configuration

public struct CacheConfiguration: Sendable {
    public let strategy: CacheStrategy
    public let evictionPolicy: EvictionPolicy
    public let maxMemorySize: Int
    public let maxDiskSize: Int
    public let defaultTTL: TimeInterval
    public let enableCompression: Bool
    public let enableEncryption: Bool
    public let diskCacheURL: URL
    public let cleanupInterval: TimeInterval
    
    public init(
        strategy: CacheStrategy = .hybrid,
        evictionPolicy: EvictionPolicy = .lru,
        maxMemorySize: Int = 100 * 1024 * 1024,  // 100MB
        maxDiskSize: Int = 500 * 1024 * 1024,    // 500MB
        defaultTTL: TimeInterval = 3600,          // 1 hour
        enableCompression: Bool = true,
        enableEncryption: Bool = false,
        diskCacheURL: URL? = nil,
        cleanupInterval: TimeInterval = 300       // 5 minutes
    ) {
        self.strategy = strategy
        self.evictionPolicy = evictionPolicy
        self.maxMemorySize = maxMemorySize
        self.maxDiskSize = maxDiskSize
        self.defaultTTL = defaultTTL
        self.enableCompression = enableCompression
        self.enableEncryption = enableEncryption
        self.diskCacheURL = diskCacheURL ?? FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
            .appendingPathComponent("SwiftIntelligenceCache")
        self.cleanupInterval = cleanupInterval
    }
    
    public static let `default` = CacheConfiguration()
    
    public static let memoryOnly = CacheConfiguration(
        strategy: .memoryOnly,
        maxDiskSize: 0,
        enableCompression: false
    )
    
    public static let diskOnly = CacheConfiguration(
        strategy: .diskOnly,
        maxMemorySize: 0
    )
    
    public static let highPerformance = CacheConfiguration(
        strategy: .hybrid,
        evictionPolicy: .lfu,
        maxMemorySize: 200 * 1024 * 1024,
        maxDiskSize: 1024 * 1024 * 1024,
        enableCompression: true,
        cleanupInterval: 60
    )
    
    public static let lowMemory = CacheConfiguration(
        strategy: .diskOnly,
        maxMemorySize: 10 * 1024 * 1024,
        maxDiskSize: 100 * 1024 * 1024,
        enableCompression: true
    )
    
    public static let secure = CacheConfiguration(
        strategy: .hybrid,
        enableCompression: true,
        enableEncryption: true
    )
}

// MARK: - Cache Strategies

public enum CacheStrategy: String, CaseIterable, Codable, Sendable {
    case memoryOnly = "memory_only"
    case diskOnly = "disk_only"
    case hybrid = "hybrid"
    
    public var description: String {
        switch self {
        case .memoryOnly: return "Memory Only"
        case .diskOnly: return "Disk Only"
        case .hybrid: return "Hybrid (Memory + Disk)"
        }
    }
}

// MARK: - Eviction Policies

public enum EvictionPolicy: String, CaseIterable, Codable, Sendable {
    case lru = "lru"   // Least Recently Used
    case lfu = "lfu"   // Least Frequently Used
    case fifo = "fifo" // First In, First Out
    case random = "random"
    
    public var description: String {
        switch self {
        case .lru: return "Least Recently Used"
        case .lfu: return "Least Frequently Used"
        case .fifo: return "First In, First Out"
        case .random: return "Random"
        }
    }
}

// MARK: - Cache Entry

public struct CacheEntry<T: Codable & Sendable>: Codable, Sendable {
    public let key: String
    public let value: T
    public let createdAt: Date
    public let expiresAt: Date?
    public let accessCount: Int
    public let lastAccessedAt: Date
    public let size: Int
    public let metadata: [String: String]
    
    public init(
        key: String,
        value: T,
        ttl: TimeInterval? = nil,
        accessCount: Int = 1,
        size: Int = 0,
        metadata: [String: String] = [:]
    ) {
        self.key = key
        self.value = value
        self.createdAt = Date()
        self.expiresAt = ttl.map { Date().addingTimeInterval($0) }
        self.accessCount = accessCount
        self.lastAccessedAt = Date()
        self.size = size
        self.metadata = metadata
    }
    
    public var isExpired: Bool {
        guard let expiresAt = expiresAt else { return false }
        return Date() > expiresAt
    }
    
    public var timeToLive: TimeInterval? {
        guard let expiresAt = expiresAt else { return nil }
        let remaining = expiresAt.timeIntervalSince(Date())
        return remaining > 0 ? remaining : 0
    }
    
    public func withUpdatedAccess() -> CacheEntry<T> {
        return CacheEntry(
            key: key,
            value: value,
            ttl: timeToLive,
            accessCount: accessCount + 1,
            size: size,
            metadata: metadata
        )
    }
}

// MARK: - Memory Cache

public actor MemoryCache {
    private var cache: [String: AnyCacheEntry] = [:]
    private var accessOrder: [String] = []
    private var maxSize: Int
    private var currentSize: Int = 0
    
    public init(maxSize: Int = 100 * 1024 * 1024) {
        self.maxSize = maxSize
    }
    
    public func get<T: Codable & Sendable>(_ key: String, as type: T.Type) -> T? {
        guard let anyEntry = cache[key] else { return nil }
        guard let entry = anyEntry.entry as? CacheEntry<T> else { return nil }
        
        // Check if expired
        if entry.isExpired {
            cache.removeValue(forKey: key)
            accessOrder.removeAll { $0 == key }
            currentSize -= entry.size
            return nil
        }
        
        // Update access order for LRU
        if let index = accessOrder.firstIndex(of: key) {
            accessOrder.remove(at: index)
        }
        accessOrder.append(key)
        
        // Update access count
        let updatedEntry = entry.withUpdatedAccess()
        cache[key] = AnyCacheEntry(updatedEntry)
        
        return entry.value
    }
    
    public func set<T: Codable & Sendable>(_ key: String, value: T, ttl: TimeInterval? = nil) {
        let dataSize = estimateSize(of: value)
        let entry = CacheEntry(key: key, value: value, ttl: ttl, size: dataSize)
        
        // Remove existing entry if present
        if let existingEntry = cache[key] {
            currentSize -= existingEntry.size
            accessOrder.removeAll { $0 == key }
        }
        
        // Add new entry
        cache[key] = AnyCacheEntry(entry)
        accessOrder.append(key)
        currentSize += dataSize
        
        // Evict if necessary
        evictIfNeeded()
    }
    
    public func delete(_ key: String) {
        if let entry = cache.removeValue(forKey: key) {
            currentSize -= entry.size
            accessOrder.removeAll { $0 == key }
        }
    }
    
    public func exists(_ key: String) -> Bool {
        guard let anyEntry = cache[key] else { return false }
        
        // Check if expired
        if anyEntry.isExpired {
            cache.removeValue(forKey: key)
            accessOrder.removeAll { $0 == key }
            currentSize -= anyEntry.size
            return false
        }
        
        return true
    }
    
    public func clearAll() {
        cache.removeAll()
        accessOrder.removeAll()
        currentSize = 0
    }
    
    public func clearExpired() -> Int {
        var clearedCount = 0
        let expiredKeys = cache.compactMap { (key, entry) in
            entry.isExpired ? key : nil
        }
        
        for key in expiredKeys {
            if let entry = cache.removeValue(forKey: key) {
                currentSize -= entry.size
                accessOrder.removeAll { $0 == key }
                clearedCount += 1
            }
        }
        
        return clearedCount
    }
    
    public func getCurrentSize() -> Int {
        return currentSize
    }
    
    public func getKeysForEviction(policy: EvictionPolicy) -> [String] {
        guard !cache.isEmpty else { return [] }
        
        let targetEvictionSize = currentSize / 4 // Evict 25% when full
        var keysToEvict: [String] = []
        var evictedSize = 0
        
        switch policy {
        case .lru:
            // Evict least recently used
            for key in accessOrder {
                if let entry = cache[key] {
                    keysToEvict.append(key)
                    evictedSize += entry.size
                    if evictedSize >= targetEvictionSize { break }
                }
            }
        case .lfu:
            // Evict least frequently used
            let sortedByFrequency = cache.sorted { $0.value.accessCount < $1.value.accessCount }
            for (key, entry) in sortedByFrequency {
                keysToEvict.append(key)
                evictedSize += entry.size
                if evictedSize >= targetEvictionSize { break }
            }
        case .fifo:
            // Evict first in, first out (oldest)
            let sortedByAge = cache.sorted { $0.value.createdAt < $1.value.createdAt }
            for (key, entry) in sortedByAge {
                keysToEvict.append(key)
                evictedSize += entry.size
                if evictedSize >= targetEvictionSize { break }
            }
        case .random:
            // Evict random entries
            let keys = Array(cache.keys)
            while evictedSize < targetEvictionSize && !keys.isEmpty {
                if let randomKey = keys.randomElement(),
                   let entry = cache[randomKey] {
                    keysToEvict.append(randomKey)
                    evictedSize += entry.size
                }
            }
        }
        
        return keysToEvict
    }
    
    public func validate() -> Bool {
        return maxSize > 0 && currentSize >= 0
    }
    
    public func updateConfiguration(maxSize: Int) {
        self.maxSize = maxSize
        evictIfNeeded()
    }
    
    public func getStatistics() -> CacheStatistics {
        return CacheStatistics(
            totalHits: 0, // This would be tracked separately
            totalMisses: 0,
            hitRate: 0.0,
            memorySize: currentSize,
            diskSize: 0,
            totalSize: currentSize,
            entryCount: cache.count,
            evictedEntries: 0,
            expiredEntries: 0
        )
    }
    
    private func evictIfNeeded() {
        while currentSize > maxSize && !cache.isEmpty {
            if let oldestKey = accessOrder.first {
                delete(oldestKey)
            } else {
                break
            }
        }
    }
    
    private func estimateSize<T: Codable>(of value: T) -> Int {
        // Simple size estimation - in production, this would be more sophisticated
        do {
            let data = try JSONEncoder().encode(value)
            return data.count
        } catch {
            return 256 // Default estimate
        }
    }
}

// MARK: - Disk Cache

public actor DiskCache {
    private let baseURL: URL
    private var maxSize: Int
    private var indexCache: [String: DiskCacheIndex] = [:]
    private let fileManager = FileManager.default
    
    public init(maxSize: Int = 500 * 1024 * 1024, baseURL: URL) {
        self.maxSize = maxSize
        self.baseURL = baseURL
        Task {
            await createCacheDirectoryIfNeeded()
            await loadIndexCache()
        }
    }
    
    public func get<T: Codable & Sendable>(_ key: String, as type: T.Type) -> T? {
        guard let index = indexCache[key] else { return nil }
        
        // Check if expired
        if index.isExpired {
            delete(key)
            return nil
        }
        
        let fileURL = baseURL.appendingPathComponent(index.filename)
        
        do {
            let data = try Data(contentsOf: fileURL)
            let entry = try JSONDecoder().decode(CacheEntry<T>.self, from: data)
            
            // Update access information
            let updatedIndex = index.withUpdatedAccess()
            indexCache[key] = updatedIndex
            saveIndexCache()
            
            return entry.value
        } catch {
            // File might be corrupted, remove it
            delete(key)
            return nil
        }
    }
    
    public func set<T: Codable & Sendable>(_ key: String, value: T, ttl: TimeInterval? = nil) {
        let entry = CacheEntry(key: key, value: value, ttl: ttl)
        let filename = generateFilename(for: key)
        let fileURL = baseURL.appendingPathComponent(filename)
        
        do {
            let data = try JSONEncoder().encode(entry)
            try data.write(to: fileURL)
            
            // Update index
            let index = DiskCacheIndex(
                key: key,
                filename: filename,
                size: data.count,
                createdAt: Date(),
                expiresAt: entry.expiresAt,
                accessCount: 1,
                lastAccessedAt: Date()
            )
            
            indexCache[key] = index
            saveIndexCache()
            
        } catch {
            // Handle write error
            print("Failed to write cache entry: \(error)")
        }
    }
    
    public func delete(_ key: String) {
        guard let index = indexCache.removeValue(forKey: key) else { return }
        
        let fileURL = baseURL.appendingPathComponent(index.filename)
        try? fileManager.removeItem(at: fileURL)
        
        saveIndexCache()
    }
    
    public func exists(_ key: String) -> Bool {
        guard let index = indexCache[key] else { return false }
        
        // Check if expired
        if index.isExpired {
            delete(key)
            return false
        }
        
        return true
    }
    
    public func clearAll() {
        try? fileManager.removeItem(at: baseURL)
        indexCache.removeAll()
        createCacheDirectoryIfNeeded()
        saveIndexCache()
    }
    
    public func clearExpired() -> Int {
        var clearedCount = 0
        let expiredKeys = indexCache.compactMap { (key, index) in
            index.isExpired ? key : nil
        }
        
        for key in expiredKeys {
            delete(key)
            clearedCount += 1
        }
        
        return clearedCount
    }
    
    public func getCurrentSize() -> Int {
        return indexCache.values.reduce(0) { $0 + $1.size }
    }
    
    public func getKeysForEviction(policy: EvictionPolicy) -> [String] {
        guard !indexCache.isEmpty else { return [] }
        
        let currentSize = getCurrentSize()
        let targetEvictionSize = currentSize / 4 // Evict 25% when full
        var keysToEvict: [String] = []
        var evictedSize = 0
        
        let sortedEntries: [(String, DiskCacheIndex)]
        
        switch policy {
        case .lru:
            sortedEntries = indexCache.sorted { $0.value.lastAccessedAt < $1.value.lastAccessedAt }
        case .lfu:
            sortedEntries = indexCache.sorted { $0.value.accessCount < $1.value.accessCount }
        case .fifo:
            sortedEntries = indexCache.sorted { $0.value.createdAt < $1.value.createdAt }
        case .random:
            sortedEntries = Array(indexCache).shuffled()
        }
        
        for (key, index) in sortedEntries {
            keysToEvict.append(key)
            evictedSize += index.size
            if evictedSize >= targetEvictionSize { break }
        }
        
        return keysToEvict
    }
    
    public func validateDirectory() -> Bool {
        return fileManager.fileExists(atPath: baseURL.path)
    }
    
    public func updateConfiguration(maxSize: Int) {
        self.maxSize = maxSize
    }
    
    public func getStatistics() -> CacheStatistics {
        return CacheStatistics(
            totalHits: 0,
            totalMisses: 0,
            hitRate: 0.0,
            memorySize: 0,
            diskSize: getCurrentSize(),
            totalSize: getCurrentSize(),
            entryCount: indexCache.count,
            evictedEntries: 0,
            expiredEntries: 0
        )
    }
    
    private func createCacheDirectoryIfNeeded() {
        try? fileManager.createDirectory(at: baseURL, withIntermediateDirectories: true)
    }
    
    private func generateFilename(for key: String) -> String {
        return key.data(using: .utf8)?.base64EncodedString()
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-") ?? UUID().uuidString
    }
    
    private func loadIndexCache() {
        let indexURL = baseURL.appendingPathComponent("index.json")
        guard let data = try? Data(contentsOf: indexURL),
              let index = try? JSONDecoder().decode([String: DiskCacheIndex].self, from: data) else {
            return
        }
        
        indexCache = index
    }
    
    private func saveIndexCache() {
        let indexURL = baseURL.appendingPathComponent("index.json")
        guard let data = try? JSONEncoder().encode(indexCache) else { return }
        try? data.write(to: indexURL)
    }
}

// MARK: - Supporting Types

public struct DiskCacheIndex: Codable {
    public let key: String
    public let filename: String
    public let size: Int
    public let createdAt: Date
    public let expiresAt: Date?
    public let accessCount: Int
    public let lastAccessedAt: Date
    
    public init(
        key: String,
        filename: String,
        size: Int,
        createdAt: Date,
        expiresAt: Date? = nil,
        accessCount: Int = 0,
        lastAccessedAt: Date
    ) {
        self.key = key
        self.filename = filename
        self.size = size
        self.createdAt = createdAt
        self.expiresAt = expiresAt
        self.accessCount = accessCount
        self.lastAccessedAt = lastAccessedAt
    }
    
    public var isExpired: Bool {
        guard let expiresAt = expiresAt else { return false }
        return Date() > expiresAt
    }
    
    public func withUpdatedAccess() -> DiskCacheIndex {
        return DiskCacheIndex(
            key: key,
            filename: filename,
            size: size,
            createdAt: createdAt,
            expiresAt: expiresAt,
            accessCount: accessCount + 1,
            lastAccessedAt: Date()
        )
    }
}

// Type-erased wrapper for cache entries
public struct AnyCacheEntry {
    public let entry: Any
    public let size: Int
    public let createdAt: Date
    public let isExpired: Bool
    public let accessCount: Int
    
    public init<T: Codable>(_ entry: CacheEntry<T>) {
        self.entry = entry
        self.size = entry.size
        self.createdAt = entry.createdAt
        self.isExpired = entry.isExpired
        self.accessCount = entry.accessCount
    }
}

// MARK: - Cache Statistics

public struct CacheStatistics: Codable, Sendable {
    public let totalHits: Int
    public let totalMisses: Int
    public let hitRate: Float
    public let memorySize: Int
    public let diskSize: Int
    public let totalSize: Int
    public let entryCount: Int
    public let evictedEntries: Int
    public let expiredEntries: Int
    
    public init(
        totalHits: Int,
        totalMisses: Int,
        hitRate: Float,
        memorySize: Int,
        diskSize: Int,
        totalSize: Int,
        entryCount: Int,
        evictedEntries: Int,
        expiredEntries: Int
    ) {
        self.totalHits = totalHits
        self.totalMisses = totalMisses
        self.hitRate = hitRate
        self.memorySize = memorySize
        self.diskSize = diskSize
        self.totalSize = totalSize
        self.entryCount = entryCount
        self.evictedEntries = evictedEntries
        self.expiredEntries = expiredEntries
    }
}

// MARK: - Cache Health

public struct CacheHealth: Codable, Sendable {
    public let healthScore: Float
    public let memoryUsage: Float
    public let diskUsage: Float
    public let hitRate: Float
    public let isHealthy: Bool
    public let recommendations: [String]
    
    public init(
        healthScore: Float,
        memoryUsage: Float,
        diskUsage: Float,
        hitRate: Float,
        isHealthy: Bool,
        recommendations: [String]
    ) {
        self.healthScore = healthScore
        self.memoryUsage = memoryUsage
        self.diskUsage = diskUsage
        self.hitRate = hitRate
        self.isHealthy = isHealthy
        self.recommendations = recommendations
    }
}

// MARK: - Cache Errors

public enum CacheError: LocalizedError, Sendable {
    case keyNotFound(String)
    case encodingFailed(String)
    case decodingFailed(String)
    case diskWriteFailed(String)
    case diskReadFailed(String)
    case invalidConfiguration(String)
    case cacheNotReady
    case insufficientSpace
    case operationTimeout
    
    public var errorDescription: String? {
        switch self {
        case .keyNotFound(let key):
            return "Cache key not found: \(key)"
        case .encodingFailed(let message):
            return "Failed to encode cache entry: \(message)"
        case .decodingFailed(let message):
            return "Failed to decode cache entry: \(message)"
        case .diskWriteFailed(let message):
            return "Failed to write to disk cache: \(message)"
        case .diskReadFailed(let message):
            return "Failed to read from disk cache: \(message)"
        case .invalidConfiguration(let message):
            return "Invalid cache configuration: \(message)"
        case .cacheNotReady:
            return "Cache engine is not ready"
        case .insufficientSpace:
            return "Insufficient cache space available"
        case .operationTimeout:
            return "Cache operation timed out"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .keyNotFound:
            return "Check if the key exists before accessing"
        case .encodingFailed, .decodingFailed:
            return "Ensure the cached type conforms to Codable"
        case .diskWriteFailed, .diskReadFailed:
            return "Check disk space and permissions"
        case .invalidConfiguration:
            return "Review and correct cache configuration"
        case .cacheNotReady:
            return "Wait for cache initialization to complete"
        case .insufficientSpace:
            return "Clear cache or increase cache limits"
        case .operationTimeout:
            return "Retry the operation or increase timeout"
        }
    }
}

// MARK: - Extensions

extension CacheConfiguration: CustomStringConvertible {
    public var description: String {
        return """
        CacheConfiguration:
        - Strategy: \(strategy.description)
        - Eviction: \(evictionPolicy.description)
        - Memory: \(maxMemorySize / (1024 * 1024))MB
        - Disk: \(maxDiskSize / (1024 * 1024))MB
        - TTL: \(defaultTTL)s
        - Compression: \(enableCompression)
        - Encryption: \(enableEncryption)
        """
    }
}

extension CacheStatistics: CustomStringConvertible {
    public var description: String {
        return """
        CacheStatistics:
        - Hit Rate: \(String(format: "%.2f%%", hitRate * 100))
        - Total Size: \(totalSize / (1024 * 1024))MB
        - Entries: \(entryCount)
        - Hits: \(totalHits), Misses: \(totalMisses)
        - Evicted: \(evictedEntries), Expired: \(expiredEntries)
        """
    }
}