import SwiftUI
import SwiftIntelligenceCache
import SwiftIntelligenceCore

struct CacheDemoView: View {
    @EnvironmentObject var appManager: DemoAppManager
    @State private var selectedFeature: CacheFeature = .basicCache
    @State private var isProcessing = false
    @State private var cacheResults: [CacheResult] = []
    @State private var cacheStats: CacheStatistics?
    @State private var refreshTimer: Timer?
    
    // Basic Cache states
    @State private var cacheKey: String = "user_profile_123"
    @State private var cacheValue: String = """
    {
      "id": 123,
      "name": "John Doe",
      "email": "john@example.com",
      "preferences": {
        "theme": "dark",
        "notifications": true
      }
    }
    """
    @State private var cacheTTL: Double = 300 // 5 minutes
    
    // Memory Cache states
    @State private var memoryCacheEntries: [CacheEntry] = []
    
    // Disk Cache states
    @State private var diskCacheEntries: [CacheEntry] = []
    
    enum CacheFeature: String, CaseIterable {
        case basicCache = "Basic Cache Operations"
        case memoryCache = "Memory Cache"
        case diskCache = "Disk Cache"
        case hybridCache = "Hybrid Cache"
        case cacheStrategies = "Cache Strategies"
        case cacheAnalytics = "Cache Analytics"
        
        var icon: String {
            switch self {
            case .basicCache: return "archivebox"
            case .memoryCache: return "memorychip"
            case .diskCache: return "externaldrive"
            case .hybridCache: return "externaldrive.connected.to.line.below"
            case .cacheStrategies: return "gear.badge"
            case .cacheAnalytics: return "chart.bar"
            }
        }
        
        var description: String {
            switch self {
            case .basicCache: return "Simple key-value caching with TTL support"
            case .memoryCache: return "Fast in-memory caching for frequently accessed data"
            case .diskCache: return "Persistent disk-based caching for large data"
            case .hybridCache: return "Intelligent hybrid memory and disk caching"
            case .cacheStrategies: return "LRU, LFU, and custom eviction policies"
            case .cacheAnalytics: return "Cache performance metrics and analytics"
            }
        }
        
        var color: Color {
            switch self {
            case .basicCache: return .blue
            case .memoryCache: return .green
            case .diskCache: return .orange
            case .hybridCache: return .purple
            case .cacheStrategies: return .red
            case .cacheAnalytics: return .cyan
            }
        }
    }
    
    struct CacheEntry: Identifiable {
        let id = UUID()
        let key: String
        let size: Int
        let ttl: TimeInterval?
        let createdAt: Date
        let accessCount: Int
        let lastAccessed: Date
        let location: CacheLocation
        
        enum CacheLocation: String {
            case memory = "Memory"
            case disk = "Disk"
            case both = "Both"
        }
    }
    
    struct CacheResult: Identifiable {
        let id = UUID()
        let feature: CacheFeature
        let operation: String
        let result: String
        let details: [String: String]
        let timestamp: Date
        let duration: TimeInterval
        let success: Bool
    }
    
    struct CacheStatistics {
        let totalEntries: Int
        let memoryEntries: Int
        let diskEntries: Int
        let totalSize: Int
        let memorySize: Int
        let diskSize: Int
        let hitRate: Float
        let missRate: Float
        let evictionCount: Int
        let compressionRatio: Float
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "externaldrive.fill.badge.checkmark")
                            .foregroundColor(.mint)
                            .font(.title)
                        Text("Intelligent Cache Engine")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    Text("Smart caching with memory, disk, and hybrid storage strategies")
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                // Cache Statistics
                if let stats = cacheStats {
                    cacheStatisticsSection(stats)
                    Divider()
                }
                
                // Feature Selection
                VStack(alignment: .leading, spacing: 16) {
                    Text("Cache Features")
                        .font(.headline)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(CacheFeature.allCases, id: \.rawValue) { feature in
                            Button(action: {
                                selectedFeature = feature
                            }) {
                                VStack(spacing: 6) {
                                    Image(systemName: feature.icon)
                                        .font(.title2)
                                        .foregroundColor(selectedFeature == feature ? .white : feature.color)
                                    Text(feature.rawValue)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(selectedFeature == feature ? .white : .primary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(height: 70)
                                .frame(maxWidth: .infinity)
                                .background(selectedFeature == feature ? feature.color : feature.color.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                    }
                    
                    Text(selectedFeature.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)
                }
                
                Divider()
                
                // Feature-Specific UI
                switch selectedFeature {
                case .basicCache:
                    basicCacheSection
                case .memoryCache:
                    memoryCacheSection
                case .diskCache:
                    diskCacheSection
                case .hybridCache:
                    hybridCacheSection
                case .cacheStrategies:
                    cacheStrategiesSection
                case .cacheAnalytics:
                    cacheAnalyticsSection
                }
                
                if !cacheResults.isEmpty {
                    Divider()
                    
                    // Results History
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Cache Operations History")
                            .font(.headline)
                        
                        ForEach(cacheResults.reversed()) { result in
                            CacheResultCard(result: result)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Cache Engine")
        .onAppear {
            startStatsRefresh()
        }
        .onDisappear {
            stopStatsRefresh()
        }
    }
    
    // MARK: - Cache Statistics Section
    
    private func cacheStatisticsSection(_ stats: CacheStatistics) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cache Statistics")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                StatCard(
                    title: "Total Entries",
                    value: "\(stats.totalEntries)",
                    subtitle: "Memory: \(stats.memoryEntries), Disk: \(stats.diskEntries)",
                    color: .blue
                )
                
                StatCard(
                    title: "Cache Size",
                    value: formatBytes(stats.totalSize),
                    subtitle: "Memory: \(formatBytes(stats.memorySize)), Disk: \(formatBytes(stats.diskSize))",
                    color: .green
                )
                
                StatCard(
                    title: "Hit Rate",
                    value: String(format: "%.1f%%", stats.hitRate * 100),
                    subtitle: "Miss Rate: \(String(format: "%.1f%%", stats.missRate * 100))",
                    color: .orange
                )
                
                StatCard(
                    title: "Efficiency",
                    value: "Evicted: \(stats.evictionCount)",
                    subtitle: "Compression: \(String(format: "%.1f%%", stats.compressionRatio * 100))",
                    color: .purple
                )
            }
        }
    }
    
    // MARK: - Feature Sections
    
    private var basicCacheSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Basic Cache Operations")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                // Cache Key Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Cache Key:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("Enter cache key", text: $cacheKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Cache Value Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Cache Value (JSON):")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextEditor(text: $cacheValue)
                        .frame(minHeight: 100)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .font(.system(.caption, design: .monospaced))
                }
                
                // TTL Setting
                VStack(alignment: .leading, spacing: 8) {
                    Text("Time To Live (TTL): \(Int(cacheTTL)) seconds")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Slider(value: $cacheTTL, in: 60...3600, step: 60) {
                        Text("TTL")
                    }
                    .accentColor(.blue)
                }
                
                // Cache Operations
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                    Button("Set Cache") {
                        Task {
                            await performSetCache()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isProcessing || cacheKey.isEmpty)
                    
                    Button("Get Cache") {
                        Task {
                            await performGetCache()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing || cacheKey.isEmpty)
                    
                    Button("Delete Cache") {
                        Task {
                            await performDeleteCache()
                        }
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                    .disabled(isProcessing || cacheKey.isEmpty)
                    
                    Button("Check Exists") {
                        Task {
                            await performCheckExists()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing || cacheKey.isEmpty)
                }
            }
        }
    }
    
    private var memoryCacheSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Memory Cache Operations")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Fast in-memory caching for frequently accessed data")
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                    Button("Load Sample Data") {
                        Task {
                            await loadSampleMemoryData()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isProcessing)
                    
                    Button("Clear Memory Cache") {
                        Task {
                            await clearMemoryCache()
                        }
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                    .disabled(isProcessing)
                    
                    Button("Memory Usage") {
                        Task {
                            await checkMemoryUsage()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                    
                    Button("Trim Memory") {
                        Task {
                            await trimMemoryCache()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                }
                
                // Memory Cache Entries
                if !memoryCacheEntries.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Memory Cache Entries:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        ScrollView {
                            LazyVStack(spacing: 4) {
                                ForEach(memoryCacheEntries) { entry in
                                    CacheEntryRow(entry: entry)
                                }
                            }
                        }
                        .frame(maxHeight: 150)
                        .padding(8)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(10)
                    }
                }
            }
        }
    }
    
    private var diskCacheSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Disk Cache Operations")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Persistent disk-based caching for large data and long-term storage")
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                    Button("Cache Large Data") {
                        Task {
                            await cacheLargeData()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isProcessing)
                    
                    Button("List Disk Cache") {
                        Task {
                            await listDiskCache()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                    
                    Button("Disk Usage") {
                        Task {
                            await checkDiskUsage()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                    
                    Button("Cleanup Disk") {
                        Task {
                            await cleanupDiskCache()
                        }
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                    .disabled(isProcessing)
                }
                
                // Disk Cache Entries
                if !diskCacheEntries.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Disk Cache Entries:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        ScrollView {
                            LazyVStack(spacing: 4) {
                                ForEach(diskCacheEntries) { entry in
                                    CacheEntryRow(entry: entry)
                                }
                            }
                        }
                        .frame(maxHeight: 150)
                        .padding(8)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(10)
                    }
                }
            }
        }
    }
    
    private var hybridCacheSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Hybrid Cache System")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Intelligent caching that automatically decides between memory and disk storage")
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                    Button("Auto Cache Data") {
                        Task {
                            await performAutoCaching()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isProcessing)
                    
                    Button("Smart Retrieve") {
                        Task {
                            await performSmartRetrieve()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                    
                    Button("Cache Migration") {
                        Task {
                            await performCacheMigration()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                    
                    Button("Optimize Cache") {
                        Task {
                            await optimizeCache()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                }
            }
        }
    }
    
    private var cacheStrategiesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Cache Strategies & Policies")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Test different eviction policies and caching strategies")
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                    Button("Test LRU Policy") {
                        Task {
                            await testLRUPolicy()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isProcessing)
                    
                    Button("Test LFU Policy") {
                        Task {
                            await testLFUPolicy()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                    
                    Button("Test TTL Expiry") {
                        Task {
                            await testTTLExpiry()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                    
                    Button("Custom Strategy") {
                        Task {
                            await testCustomStrategy()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                }
            }
        }
    }
    
    private var cacheAnalyticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Cache Performance Analytics")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Comprehensive cache performance metrics and insights")
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                    Button("Performance Report") {
                        Task {
                            await generatePerformanceReport()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isProcessing)
                    
                    Button("Hit Rate Analysis") {
                        Task {
                            await analyzeHitRates()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                    
                    Button("Memory Efficiency") {
                        Task {
                            await analyzeMemoryEfficiency()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                    
                    Button("Export Metrics") {
                        Task {
                            await exportCacheMetrics()
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(isProcessing)
                }
            }
        }
    }
    
    // MARK: - Cache Operations
    
    @MainActor
    private func performSetCache() async {
        guard let cacheEngine = appManager.getCacheEngine() else { return }
        
        isProcessing = true
        let startTime = Date()
        
        do {
            try await cacheEngine.set(cacheKey, value: cacheValue, ttl: cacheTTL)
            let duration = Date().timeIntervalSince(startTime)
            
            let cacheResult = CacheResult(
                feature: .basicCache,
                operation: "Set Cache",
                result: "Data cached successfully",
                details: [
                    "Key": cacheKey,
                    "Size": "\(cacheValue.count) characters",
                    "TTL": "\(Int(cacheTTL)) seconds",
                    "Expiry": dateFormatter.string(from: Date().addingTimeInterval(cacheTTL))
                ],
                timestamp: Date(),
                duration: duration,
                success: true
            )
            
            cacheResults.insert(cacheResult, at: 0)
            await refreshCacheStats()
            
        } catch {
            let errorResult = CacheResult(
                feature: .basicCache,
                operation: "Set Cache",
                result: "Cache failed: \(error.localizedDescription)",
                details: [:],
                timestamp: Date(),
                duration: Date().timeIntervalSince(startTime),
                success: false
            )
            cacheResults.insert(errorResult, at: 0)
        }
        
        isProcessing = false
    }
    
    @MainActor
    private func performGetCache() async {
        guard let cacheEngine = appManager.getCacheEngine() else { return }
        
        isProcessing = true
        let startTime = Date()
        
        do {
            let cachedValue: String? = try await cacheEngine.get(cacheKey, as: String.self)
            let duration = Date().timeIntervalSince(startTime)
            
            let cacheResult = CacheResult(
                feature: .basicCache,
                operation: "Get Cache",
                result: cachedValue != nil ? "Data retrieved successfully" : "Cache miss - no data found",
                details: [
                    "Key": cacheKey,
                    "Found": cachedValue != nil ? "Yes" : "No",
                    "Size": cachedValue != nil ? "\(cachedValue!.count) characters" : "N/A",
                    "Preview": cachedValue?.prefix(50).appending("...") ?? "No data"
                ],
                timestamp: Date(),
                duration: duration,
                success: cachedValue != nil
            )
            
            cacheResults.insert(cacheResult, at: 0)
            await refreshCacheStats()
            
        } catch {
            let errorResult = CacheResult(
                feature: .basicCache,
                operation: "Get Cache",
                result: "Retrieval failed: \(error.localizedDescription)",
                details: [:],
                timestamp: Date(),
                duration: Date().timeIntervalSince(startTime),
                success: false
            )
            cacheResults.insert(errorResult, at: 0)
        }
        
        isProcessing = false
    }
    
    @MainActor
    private func performDeleteCache() async {
        guard let cacheEngine = appManager.getCacheEngine() else { return }
        
        isProcessing = true
        let startTime = Date()
        
        do {
            try await cacheEngine.delete(cacheKey)
            let duration = Date().timeIntervalSince(startTime)
            
            let cacheResult = CacheResult(
                feature: .basicCache,
                operation: "Delete Cache",
                result: "Cache entry deleted",
                details: [
                    "Key": cacheKey
                ],
                timestamp: Date(),
                duration: duration,
                success: true
            )
            
            cacheResults.insert(cacheResult, at: 0)
            await refreshCacheStats()
            
        } catch {
            let errorResult = CacheResult(
                feature: .basicCache,
                operation: "Delete Cache",
                result: "Deletion failed: \(error.localizedDescription)",
                details: [:],
                timestamp: Date(),
                duration: Date().timeIntervalSince(startTime),
                success: false
            )
            cacheResults.insert(errorResult, at: 0)
        }
        
        isProcessing = false
    }
    
    @MainActor
    private func performCheckExists() async {
        guard let cacheEngine = appManager.getCacheEngine() else { return }
        
        isProcessing = true
        let startTime = Date()
        
        do {
            let exists = try await cacheEngine.exists(cacheKey)
            let duration = Date().timeIntervalSince(startTime)
            
            let cacheResult = CacheResult(
                feature: .basicCache,
                operation: "Check Exists",
                result: exists ? "Cache entry exists" : "Cache entry not found",
                details: [
                    "Key": cacheKey,
                    "Exists": exists ? "Yes" : "No"
                ],
                timestamp: Date(),
                duration: duration,
                success: true
            )
            
            cacheResults.insert(cacheResult, at: 0)
            
        } catch {
            let errorResult = CacheResult(
                feature: .basicCache,
                operation: "Check Exists",
                result: "Check failed: \(error.localizedDescription)",
                details: [:],
                timestamp: Date(),
                duration: Date().timeIntervalSince(startTime),
                success: false
            )
            cacheResults.insert(errorResult, at: 0)
        }
        
        isProcessing = false
    }
    
    // MARK: - Memory Cache Operations
    
    @MainActor
    private func loadSampleMemoryData() async {
        guard let cacheEngine = appManager.getCacheEngine() else { return }
        
        isProcessing = true
        let startTime = Date()
        
        do {
            let sampleData = generateSampleData()
            for (key, value) in sampleData {
                try await cacheEngine.setMemory(key, value: value, ttl: 600)
            }
            
            memoryCacheEntries = sampleData.map { key, value in
                CacheEntry(
                    key: key,
                    size: value.count,
                    ttl: 600,
                    createdAt: Date(),
                    accessCount: 1,
                    lastAccessed: Date(),
                    location: .memory
                )
            }
            
            let duration = Date().timeIntervalSince(startTime)
            
            let cacheResult = CacheResult(
                feature: .memoryCache,
                operation: "Load Sample Data",
                result: "Loaded \(sampleData.count) entries to memory cache",
                details: [
                    "Entries": "\(sampleData.count)",
                    "Total Size": formatBytes(sampleData.values.reduce(0) { $0 + $1.count })
                ],
                timestamp: Date(),
                duration: duration,
                success: true
            )
            
            cacheResults.insert(cacheResult, at: 0)
            await refreshCacheStats()
            
        } catch {
            let errorResult = CacheResult(
                feature: .memoryCache,
                operation: "Load Sample Data",
                result: "Loading failed: \(error.localizedDescription)",
                details: [:],
                timestamp: Date(),
                duration: Date().timeIntervalSince(startTime),
                success: false
            )
            cacheResults.insert(errorResult, at: 0)
        }
        
        isProcessing = false
    }
    
    @MainActor
    private func clearMemoryCache() async {
        guard let cacheEngine = appManager.getCacheEngine() else { return }
        
        isProcessing = true
        let startTime = Date()
        
        do {
            try await cacheEngine.clearMemory()
            memoryCacheEntries.removeAll()
            let duration = Date().timeIntervalSince(startTime)
            
            let cacheResult = CacheResult(
                feature: .memoryCache,
                operation: "Clear Memory Cache",
                result: "Memory cache cleared successfully",
                details: [:],
                timestamp: Date(),
                duration: duration,
                success: true
            )
            
            cacheResults.insert(cacheResult, at: 0)
            await refreshCacheStats()
            
        } catch {
            let errorResult = CacheResult(
                feature: .memoryCache,
                operation: "Clear Memory Cache",
                result: "Clear failed: \(error.localizedDescription)",
                details: [:],
                timestamp: Date(),
                duration: Date().timeIntervalSince(startTime),
                success: false
            )
            cacheResults.insert(errorResult, at: 0)
        }
        
        isProcessing = false
    }
    
    @MainActor
    private func checkMemoryUsage() async {
        guard let cacheEngine = appManager.getCacheEngine() else { return }
        
        isProcessing = true
        let startTime = Date()
        
        do {
            let memoryStats = try await cacheEngine.getMemoryStatistics()
            let duration = Date().timeIntervalSince(startTime)
            
            let cacheResult = CacheResult(
                feature: .memoryCache,
                operation: "Memory Usage Check",
                result: "Memory usage: \(formatBytes(memoryStats.totalSize))",
                details: [
                    "Entries": "\(memoryStats.entryCount)",
                    "Total Size": formatBytes(memoryStats.totalSize),
                    "Available": formatBytes(memoryStats.availableMemory),
                    "Usage": String(format: "%.1f%%", memoryStats.usagePercentage * 100)
                ],
                timestamp: Date(),
                duration: duration,
                success: true
            )
            
            cacheResults.insert(cacheResult, at: 0)
            
        } catch {
            let errorResult = CacheResult(
                feature: .memoryCache,
                operation: "Memory Usage Check",
                result: "Check failed: \(error.localizedDescription)",
                details: [:],
                timestamp: Date(),
                duration: Date().timeIntervalSince(startTime),
                success: false
            )
            cacheResults.insert(errorResult, at: 0)
        }
        
        isProcessing = false
    }
    
    @MainActor
    private func trimMemoryCache() async {
        guard let cacheEngine = appManager.getCacheEngine() else { return }
        
        isProcessing = true
        let startTime = Date()
        
        do {
            let trimResult = try await cacheEngine.trimMemoryCache(targetPercentage: 0.7)
            let duration = Date().timeIntervalSince(startTime)
            
            let cacheResult = CacheResult(
                feature: .memoryCache,
                operation: "Trim Memory Cache",
                result: "Trimmed \(trimResult.removedEntries) entries",
                details: [
                    "Removed Entries": "\(trimResult.removedEntries)",
                    "Freed Memory": formatBytes(trimResult.freedMemory),
                    "Remaining Entries": "\(trimResult.remainingEntries)"
                ],
                timestamp: Date(),
                duration: duration,
                success: true
            )
            
            cacheResults.insert(cacheResult, at: 0)
            await refreshCacheStats()
            
        } catch {
            let errorResult = CacheResult(
                feature: .memoryCache,
                operation: "Trim Memory Cache",
                result: "Trim failed: \(error.localizedDescription)",
                details: [:],
                timestamp: Date(),
                duration: Date().timeIntervalSince(startTime),
                success: false
            )
            cacheResults.insert(errorResult, at: 0)
        }
        
        isProcessing = false
    }
    
    // MARK: - Additional Cache Operations (Simplified implementations)
    
    @MainActor
    private func cacheLargeData() async {
        await simulateCacheOperation(
            feature: .diskCache,
            operation: "Cache Large Data",
            result: "Large dataset cached to disk",
            details: [
                "Size": "15.7 MB",
                "Compression": "Enabled",
                "Location": "Disk"
            ]
        )
    }
    
    @MainActor
    private func listDiskCache() async {
        await simulateCacheOperation(
            feature: .diskCache,
            operation: "List Disk Cache",
            result: "Found 12 disk cache entries",
            details: [
                "Total Entries": "12",
                "Total Size": "47.3 MB",
                "Oldest Entry": "3 days ago"
            ]
        )
    }
    
    @MainActor
    private func checkDiskUsage() async {
        await simulateCacheOperation(
            feature: .diskCache,
            operation: "Disk Usage Check",
            result: "Disk cache using 47.3 MB",
            details: [
                "Used Space": "47.3 MB",
                "Available": "1.2 GB",
                "Usage": "3.8%"
            ]
        )
    }
    
    @MainActor
    private func cleanupDiskCache() async {
        await simulateCacheOperation(
            feature: .diskCache,
            operation: "Cleanup Disk Cache",
            result: "Cleaned up 5 expired entries",
            details: [
                "Removed Entries": "5",
                "Freed Space": "12.1 MB",
                "Remaining": "35.2 MB"
            ]
        )
    }
    
    @MainActor
    private func performAutoCaching() async {
        await simulateCacheOperation(
            feature: .hybridCache,
            operation: "Auto Cache Data",
            result: "Data automatically distributed across memory and disk",
            details: [
                "Memory Items": "8",
                "Disk Items": "4",
                "Strategy": "Frequency-based"
            ]
        )
    }
    
    @MainActor
    private func performSmartRetrieve() async {
        await simulateCacheOperation(
            feature: .hybridCache,
            operation: "Smart Retrieve",
            result: "Data retrieved from optimal storage",
            details: [
                "Source": "Memory",
                "Fallback": "Disk available",
                "Speed": "0.8ms"
            ]
        )
    }
    
    @MainActor
    private func performCacheMigration() async {
        await simulateCacheOperation(
            feature: .hybridCache,
            operation: "Cache Migration",
            result: "Migrated 3 items from disk to memory",
            details: [
                "Migrated": "3 items",
                "Direction": "Disk → Memory",
                "Reason": "High access frequency"
            ]
        )
    }
    
    @MainActor
    private func optimizeCache() async {
        await simulateCacheOperation(
            feature: .hybridCache,
            operation: "Optimize Cache",
            result: "Cache optimized for current usage patterns",
            details: [
                "Hit Rate": "94.2%",
                "Memory Efficiency": "87%",
                "Recommendations": "3 applied"
            ]
        )
    }
    
    @MainActor
    private func testLRUPolicy() async {
        await simulateCacheOperation(
            feature: .cacheStrategies,
            operation: "Test LRU Policy",
            result: "LRU eviction policy tested successfully",
            details: [
                "Policy": "Least Recently Used",
                "Evicted Items": "2",
                "Performance": "Good"
            ]
        )
    }
    
    @MainActor
    private func testLFUPolicy() async {
        await simulateCacheOperation(
            feature: .cacheStrategies,
            operation: "Test LFU Policy",
            result: "LFU eviction policy tested successfully",
            details: [
                "Policy": "Least Frequently Used",
                "Evicted Items": "1",
                "Performance": "Excellent"
            ]
        )
    }
    
    @MainActor
    private func testTTLExpiry() async {
        await simulateCacheOperation(
            feature: .cacheStrategies,
            operation: "Test TTL Expiry",
            result: "TTL expiration tested successfully",
            details: [
                "Expired Items": "4",
                "TTL Range": "5m - 1h",
                "Cleanup": "Automatic"
            ]
        )
    }
    
    @MainActor
    private func testCustomStrategy() async {
        await simulateCacheOperation(
            feature: .cacheStrategies,
            operation: "Test Custom Strategy",
            result: "Custom eviction strategy executed",
            details: [
                "Strategy": "Priority-based",
                "Logic": "Business value + access frequency",
                "Result": "Optimal"
            ]
        )
    }
    
    @MainActor
    private func generatePerformanceReport() async {
        await simulateCacheOperation(
            feature: .cacheAnalytics,
            operation: "Performance Report",
            result: "Comprehensive performance report generated",
            details: [
                "Hit Rate": "94.2%",
                "Avg Response": "1.2ms",
                "Efficiency": "Excellent"
            ]
        )
    }
    
    @MainActor
    private func analyzeHitRates() async {
        await simulateCacheOperation(
            feature: .cacheAnalytics,
            operation: "Hit Rate Analysis",
            result: "Hit rate analysis completed",
            details: [
                "Overall Hit Rate": "94.2%",
                "Memory Hit Rate": "98.1%",
                "Disk Hit Rate": "89.7%"
            ]
        )
    }
    
    @MainActor
    private func analyzeMemoryEfficiency() async {
        await simulateCacheOperation(
            feature: .cacheAnalytics,
            operation: "Memory Efficiency Analysis",
            result: "Memory efficiency analyzed",
            details: [
                "Efficiency Score": "87%",
                "Fragmentation": "Low",
                "Optimization": "2 suggestions"
            ]
        )
    }
    
    @MainActor
    private func exportCacheMetrics() async {
        await simulateCacheOperation(
            feature: .cacheAnalytics,
            operation: "Export Metrics",
            result: "Cache metrics exported successfully",
            details: [
                "Format": "JSON",
                "Size": "2.3 KB",
                "Timespan": "Last 24h"
            ]
        )
    }
    
    // MARK: - Helper Methods
    
    private func simulateCacheOperation(
        feature: CacheFeature,
        operation: String,
        result: String,
        details: [String: String]
    ) async {
        isProcessing = true
        let startTime = Date()
        
        // Simulate processing time
        try? await Task.sleep(nanoseconds: UInt64.random(in: 300_000_000...800_000_000))
        
        let duration = Date().timeIntervalSince(startTime)
        
        let cacheResult = CacheResult(
            feature: feature,
            operation: operation,
            result: result,
            details: details,
            timestamp: Date(),
            duration: duration,
            success: true
        )
        
        cacheResults.insert(cacheResult, at: 0)
        await refreshCacheStats()
        
        isProcessing = false
    }
    
    private func generateSampleData() -> [String: String] {
        return [
            "user_123": "{'id': 123, 'name': 'John Doe', 'email': 'john@example.com'}",
            "product_456": "{'id': 456, 'name': 'iPhone 15', 'price': 999.99}",
            "session_789": "{'sessionId': '789', 'userId': 123, 'lastActivity': '2024-01-15'}",
            "config_app": "{'theme': 'dark', 'notifications': true, 'language': 'en'}",
            "metrics_daily": "{'date': '2024-01-15', 'views': 1234, 'users': 567}"
        ]
    }
    
    private func formatBytes(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
    
    private func startStatsRefresh() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            Task {
                await refreshCacheStats()
            }
        }
        
        Task {
            await refreshCacheStats()
        }
    }
    
    private func stopStatsRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    @MainActor
    private func refreshCacheStats() async {
        // Simulate cache statistics
        cacheStats = CacheStatistics(
            totalEntries: Int.random(in: 15...25),
            memoryEntries: Int.random(in: 8...12),
            diskEntries: Int.random(in: 5...15),
            totalSize: Int.random(in: 1024*1024...10*1024*1024), // 1-10 MB
            memorySize: Int.random(in: 512*1024...2*1024*1024), // 512KB-2MB
            diskSize: Int.random(in: 5*1024*1024...8*1024*1024), // 5-8MB
            hitRate: Float.random(in: 0.85...0.98),
            missRate: Float.random(in: 0.02...0.15),
            evictionCount: Int.random(in: 0...5),
            compressionRatio: Float.random(in: 0.6...0.8)
        )
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding(8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct CacheEntryRow: View {
    let entry: CacheDemoView.CacheEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(entry.key)
                    .font(.caption)
                    .fontWeight(.medium)
                Text(formatBytes(entry.size))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(entry.location.rawValue)
                    .font(.caption2)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(entry.location == .memory ? Color.green : Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(4)
                Text("\(entry.accessCount) accesses")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
    
    private func formatBytes(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

struct CacheResultCard: View {
    let result: CacheDemoView.CacheResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: result.feature.icon)
                    .foregroundColor(result.feature.color)
                VStack(alignment: .leading) {
                    Text(result.operation)
                        .font(.headline)
                    Text(timeAgoString(from: result.timestamp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: result.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(result.success ? .green : .red)
            }
            
            Text(result.result)
                .font(.body)
                .padding(10)
                .background(result.feature.color.opacity(0.1))
                .cornerRadius(8)
            
            if !result.details.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Details:")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    ForEach(result.details.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        HStack {
                            Text(key + ":")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(value)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                }
                .padding(8)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(6)
            }
            
            HStack {
                Spacer()
                Text(String(format: "%.3fs", result.duration))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}