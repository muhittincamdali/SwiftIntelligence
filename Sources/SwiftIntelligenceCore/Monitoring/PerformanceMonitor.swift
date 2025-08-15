import Foundation
import os.signpost

/// Performance monitoring system for SwiftIntelligence
@MainActor
public final class PerformanceMonitor {
    
    // MARK: - Properties
    
    private let signpostLog: OSLog
    private var activeOperations: [UUID: OperationMetrics] = [:]
    private var completedOperations: [OperationMetrics] = []
    private let maxStoredOperations = 1000
    
    /// Performance metrics delegate
    public weak var delegate: PerformanceMonitorDelegate?
    
    /// Enable detailed monitoring
    public var detailedMonitoringEnabled: Bool = false
    
    /// Current monitoring status
    public private(set) var isMonitoring: Bool = false
    
    // MARK: - Initialization
    
    public init() {
        self.signpostLog = OSLog(subsystem: "com.swiftintelligence", category: "Performance")
    }
    
    // MARK: - Monitoring Control
    
    /// Start monitoring
    public func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true
        delegate?.performanceMonitorDidStart()
    }
    
    /// Stop monitoring
    public func stopMonitoring() {
        guard isMonitoring else { return }
        isMonitoring = false
        activeOperations.removeAll()
        delegate?.performanceMonitorDidStop()
    }
    
    // MARK: - Operation Tracking
    
    /// Begin tracking an operation
    /// - Parameters:
    ///   - name: Operation name
    ///   - category: Operation category
    /// - Returns: Operation ID for tracking
    @discardableResult
    public func beginOperation(
        _ name: String,
        category: String = "General"
    ) -> UUID {
        let operationID = UUID()
        
        let metrics = OperationMetrics(
            id: operationID,
            name: name,
            category: category,
            startTime: Date(),
            startMemory: currentMemoryUsage().used
        )
        
        activeOperations[operationID] = metrics
        
        if detailedMonitoringEnabled {
            os_signpost(.begin, log: signpostLog, name: "Operation")
        }
        
        return operationID
    }
    
    /// End tracking an operation
    /// - Parameter operationID: Operation ID
    public func endOperation(_ operationID: UUID) {
        guard var metrics = activeOperations[operationID] else { return }
        
        metrics.endTime = Date()
        metrics.endMemory = currentMemoryUsage().used
        metrics.duration = metrics.endTime!.timeIntervalSince(metrics.startTime)
        metrics.memoryDelta = Int64(metrics.endMemory!) - Int64(metrics.startMemory)
        
        activeOperations.removeValue(forKey: operationID)
        completedOperations.append(metrics)
        
        // Limit stored operations
        if completedOperations.count > maxStoredOperations {
            completedOperations.removeFirst()
        }
        
        if detailedMonitoringEnabled {
            os_signpost(.end, log: signpostLog, name: "Operation")
        }
        
        delegate?.performanceMonitor(didCompleteOperation: metrics)
    }
    
    /// Measure execution time of a block
    /// - Parameters:
    ///   - name: Operation name
    ///   - block: Code block to measure
    /// - Returns: Block result
    public func measure<T>(
        _ name: String,
        block: () throws -> T
    ) rethrows -> T {
        let operationID = beginOperation(name)
        defer { endOperation(operationID) }
        return try block()
    }
    
    /// Measure async execution time
    /// - Parameters:
    ///   - name: Operation name
    ///   - block: Async code block to measure
    /// - Returns: Block result
    public func measureAsync<T: Sendable>(
        _ name: String,
        block: @Sendable () async throws -> T
    ) async rethrows -> T {
        let operationID = beginOperation(name)
        defer { endOperation(operationID) }
        return try await block()
    }
    
    // MARK: - Metrics Retrieval
    
    /// Get current memory usage
    public func currentMemoryUsage() -> MemoryUsage {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if result == KERN_SUCCESS {
            let usedMB = Double(info.resident_size) / 1024.0 / 1024.0
            let totalMB = Double(ProcessInfo.processInfo.physicalMemory) / 1024.0 / 1024.0
            
            return MemoryUsage(
                used: info.resident_size,
                total: ProcessInfo.processInfo.physicalMemory,
                usedMB: usedMB,
                totalMB: totalMB,
                percentage: (usedMB / totalMB) * 100
            )
        }
        
        return MemoryUsage(used: 0, total: 0, usedMB: 0, totalMB: 0, percentage: 0)
    }
    
    /// Get current CPU usage
    public func currentCPUUsage() -> CPUUsage {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if result == KERN_SUCCESS {
            let userTime = Double(info.user_time.seconds) + Double(info.user_time.microseconds) / 1_000_000
            let systemTime = Double(info.system_time.seconds) + Double(info.system_time.microseconds) / 1_000_000
            
            return CPUUsage(
                user: userTime,
                system: systemTime,
                total: userTime + systemTime,
                percentage: 0 // Would need historical data to calculate percentage
            )
        }
        
        return CPUUsage(user: 0, system: 0, total: 0, percentage: 0)
    }
    
    /// Get performance summary
    public func performanceSummary() -> PerformanceSummary {
        let avgDuration = completedOperations.isEmpty ? 0 :
            completedOperations.compactMap { $0.duration }.reduce(0, +) / Double(completedOperations.count)
        
        let maxDuration = completedOperations.compactMap { $0.duration }.max() ?? 0
        let minDuration = completedOperations.compactMap { $0.duration }.min() ?? 0
        
        return PerformanceSummary(
            totalOperations: completedOperations.count,
            activeOperations: activeOperations.count,
            averageDuration: avgDuration,
            maxDuration: maxDuration,
            minDuration: minDuration,
            memoryUsage: currentMemoryUsage(),
            cpuUsage: currentCPUUsage()
        )
    }
    
    /// Get operations by category
    public func operations(forCategory category: String) -> [OperationMetrics] {
        completedOperations.filter { $0.category == category }
    }
    
    /// Clear all metrics
    public func clearMetrics() {
        completedOperations.removeAll()
        activeOperations.removeAll()
    }
}

// MARK: - Supporting Types

/// Operation metrics
public struct OperationMetrics: Sendable {
    public let id: UUID
    public let name: String
    public let category: String
    public let startTime: Date
    public var endTime: Date?
    public var duration: TimeInterval?
    public let startMemory: UInt64
    public var endMemory: UInt64?
    public var memoryDelta: Int64?
}

/// Memory usage information
public struct MemoryUsage: Sendable {
    public let used: UInt64
    public let total: UInt64
    public let usedMB: Double
    public let totalMB: Double
    public let percentage: Double
}

/// CPU usage information
public struct CPUUsage: Sendable {
    public let user: Double
    public let system: Double
    public let total: Double
    public let percentage: Double
}

/// Performance summary
public struct PerformanceSummary: Sendable {
    public let totalOperations: Int
    public let activeOperations: Int
    public let averageDuration: TimeInterval
    public let maxDuration: TimeInterval
    public let minDuration: TimeInterval
    public let memoryUsage: MemoryUsage
    public let cpuUsage: CPUUsage
}

/// Performance monitor delegate
public protocol PerformanceMonitorDelegate: AnyObject {
    func performanceMonitorDidStart()
    func performanceMonitorDidStop()
    func performanceMonitor(didCompleteOperation metrics: OperationMetrics)
}