//
// BenchmarkSuite.swift
// SwiftIntelligence
//
// Created by SwiftIntelligence Framework on 16/08/2024.
//

import Foundation
import SwiftIntelligenceCore

/// Comprehensive performance benchmark suite for SwiftIntelligence Framework
@MainActor
public final class BenchmarkSuite {
    
    // MARK: - Properties
    
    private let logger = IntelligenceLogger()
    private var results: [BenchmarkResult] = []
    private var currentSession: BenchmarkSession?
    
    // MARK: - Benchmark Configuration
    
    public struct BenchmarkConfig: Sendable {
        public let iterations: Int
        public let warmupIterations: Int
        public let measurementInterval: TimeInterval
        public let memoryMeasurementEnabled: Bool
        public let cpuMeasurementEnabled: Bool
        public let batteryMeasurementEnabled: Bool
        
        public static let `default` = BenchmarkConfig(
            iterations: 100,
            warmupIterations: 10,
            measurementInterval: 0.1,
            memoryMeasurementEnabled: true,
            cpuMeasurementEnabled: true,
            batteryMeasurementEnabled: true
        )
        
        public static let quick = BenchmarkConfig(
            iterations: 10,
            warmupIterations: 2,
            measurementInterval: 0.05,
            memoryMeasurementEnabled: true,
            cpuMeasurementEnabled: false,
            batteryMeasurementEnabled: false
        )
        
        public static let comprehensive = BenchmarkConfig(
            iterations: 1000,
            warmupIterations: 50,
            measurementInterval: 0.01,
            memoryMeasurementEnabled: true,
            cpuMeasurementEnabled: true,
            batteryMeasurementEnabled: true
        )
    }
    
    // MARK: - Initialization
    
    public init() {}
    
    // MARK: - Benchmark Execution
    
    /// Run a single benchmark with specified configuration
    /// - Parameters:
    ///   - name: Benchmark name
    ///   - config: Benchmark configuration
    ///   - operation: Operation to benchmark
    /// - Returns: Benchmark result
    public func runBenchmark<T>(
        name: String,
        config: BenchmarkConfig = .default,
        operation: @escaping () async throws -> T
    ) async rethrows -> BenchmarkResult {
        logger.info("Starting benchmark: \(name)", category: "Benchmark")
        
        let session = BenchmarkSession(name: name, config: config)
        currentSession = session
        
        // Warmup phase
        logger.debug("Warmup phase: \(config.warmupIterations) iterations", category: "Benchmark")
        for _ in 0..<config.warmupIterations {
            _ = try await operation()
        }
        
        // Measurement phase
        logger.debug("Measurement phase: \(config.iterations) iterations", category: "Benchmark")
        var measurements: [BenchmarkMeasurement] = []
        
        for iteration in 0..<config.iterations {
            let measurement = try await measureOperation(
                iteration: iteration,
                config: config,
                operation: operation
            )
            measurements.append(measurement)
        }
        
        // Calculate results
        let result = calculateBenchmarkResult(
            name: name,
            measurements: measurements,
            config: config
        )
        
        results.append(result)
        currentSession = nil
        
        logger.info("Benchmark completed: \(name)", category: "Benchmark")
        logger.info("Average execution time: \(result.averageExecutionTime)s", category: "Benchmark")
        
        return result
    }
    
    /// Run multiple benchmarks in sequence
    /// - Parameters:
    ///   - benchmarks: Array of benchmark configurations
    /// - Returns: Array of benchmark results
    public func runBenchmarks(_ benchmarks: [(String, BenchmarkConfig, () async throws -> Any)]) async -> [BenchmarkResult] {
        var results: [BenchmarkResult] = []
        
        for (name, config, operation) in benchmarks {
            do {
                let result = try await runBenchmark(name: name, config: config, operation: operation)
                results.append(result)
            } catch {
                logger.error("Benchmark \(name) failed: \(error)", category: "Benchmark")
            }
        }
        
        return results
    }
    
    // MARK: - Measurement
    
    private func measureOperation<T>(
        iteration: Int,
        config: BenchmarkConfig,
        operation: () async throws -> T
    ) async throws -> BenchmarkMeasurement {
        let startTime = DispatchTime.now()
        let startMemory = config.memoryMeasurementEnabled ? getCurrentMemoryUsage() : 0
        let startCPU = config.cpuMeasurementEnabled ? getCurrentCPUUsage() : 0
        
        // Execute operation
        _ = try await operation()
        
        let endTime = DispatchTime.now()
        let endMemory = config.memoryMeasurementEnabled ? getCurrentMemoryUsage() : 0
        let endCPU = config.cpuMeasurementEnabled ? getCurrentCPUUsage() : 0
        
        let executionTime = Double(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000_000
        let memoryDelta = endMemory - startMemory
        let cpuDelta = endCPU - startCPU
        
        return BenchmarkMeasurement(
            iteration: iteration,
            executionTime: executionTime,
            memoryUsage: endMemory,
            memoryDelta: memoryDelta,
            cpuUsage: endCPU,
            cpuDelta: cpuDelta,
            timestamp: Date()
        )
    }
    
    // MARK: - System Metrics
    
    private func getCurrentMemoryUsage() -> Int64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(
                    mach_task_self_,
                    task_flavor_t(MACH_TASK_BASIC_INFO),
                    $0,
                    &count
                )
            }
        }
        
        guard result == KERN_SUCCESS else { return 0 }
        return Int64(info.resident_size)
    }
    
    private func getCurrentCPUUsage() -> Double {
        var info = proc_taskinfo()
        let result = proc_pidinfo(
            getpid(),
            PROC_PIDTASKINFO,
            0,
            &info,
            Int32(MemoryLayout<proc_taskinfo>.size)
        )
        
        guard result == Int32(MemoryLayout<proc_taskinfo>.size) else { return 0 }
        
        let totalTime = info.pti_total_user + info.pti_total_system
        return Double(totalTime) / 1_000_000_000 // Convert to seconds
    }
    
    // MARK: - Result Calculation
    
    private func calculateBenchmarkResult(
        name: String,
        measurements: [BenchmarkMeasurement],
        config: BenchmarkConfig
    ) -> BenchmarkResult {
        let executionTimes = measurements.map { $0.executionTime }
        let memoryUsages = measurements.map { $0.memoryUsage }
        let cpuUsages = measurements.map { $0.cpuUsage }
        
        return BenchmarkResult(
            name: name,
            config: config,
            measurements: measurements,
            averageExecutionTime: executionTimes.average,
            minExecutionTime: executionTimes.min() ?? 0,
            maxExecutionTime: executionTimes.max() ?? 0,
            standardDeviation: executionTimes.standardDeviation,
            averageMemoryUsage: memoryUsages.average,
            peakMemoryUsage: memoryUsages.max() ?? 0,
            averageCPUUsage: cpuUsages.average,
            peakCPUUsage: cpuUsages.max() ?? 0,
            timestamp: Date(),
            platform: getCurrentPlatform(),
            deviceModel: getDeviceModel()
        )
    }
    
    // MARK: - Platform Information
    
    private func getCurrentPlatform() -> String {
        #if os(iOS)
        return "iOS"
        #elseif os(macOS)
        return "macOS"
        #elseif os(watchOS)
        return "watchOS"
        #elseif os(tvOS)
        return "tvOS"
        #elseif os(visionOS)
        return "visionOS"
        #else
        return "Unknown"
        #endif
    }
    
    private func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let model = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0)
            }
        }
        
        return model ?? "Unknown"
    }
    
    // MARK: - Results Management
    
    /// Get all benchmark results
    public func getAllResults() -> [BenchmarkResult] {
        return results
    }
    
    /// Get results for specific benchmark
    public func getResults(for benchmarkName: String) -> [BenchmarkResult] {
        return results.filter { $0.name == benchmarkName }
    }
    
    /// Clear all results
    public func clearResults() {
        results.removeAll()
        logger.info("Benchmark results cleared", category: "Benchmark")
    }
    
    /// Export results to JSON
    public func exportResults() throws -> Data {
        let export = BenchmarkExport(
            exportDate: Date(),
            platform: getCurrentPlatform(),
            deviceModel: getDeviceModel(),
            results: results
        )
        
        return try JSONEncoder().encode(export)
    }
    
    /// Generate performance report
    public func generateReport() -> String {
        var report = "# SwiftIntelligence Performance Report\n\n"
        report += "Generated: \(Date())\n"
        report += "Platform: \(getCurrentPlatform())\n"
        report += "Device: \(getDeviceModel())\n\n"
        
        for result in results {
            report += "## \(result.name)\n"
            report += "- Average Execution Time: \(String(format: "%.4f", result.averageExecutionTime))s\n"
            report += "- Min/Max: \(String(format: "%.4f", result.minExecutionTime))s / \(String(format: "%.4f", result.maxExecutionTime))s\n"
            report += "- Standard Deviation: \(String(format: "%.4f", result.standardDeviation))s\n"
            report += "- Average Memory: \(formatBytes(result.averageMemoryUsage))\n"
            report += "- Peak Memory: \(formatBytes(result.peakMemoryUsage))\n"
            report += "- Iterations: \(result.measurements.count)\n\n"
        }
        
        return report
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
        formatter.countStyle = .memory
        return formatter.string(fromByteCount: bytes)
    }
}

// MARK: - Supporting Types

public struct BenchmarkMeasurement: Codable, Sendable {
    public let iteration: Int
    public let executionTime: TimeInterval
    public let memoryUsage: Int64
    public let memoryDelta: Int64
    public let cpuUsage: Double
    public let cpuDelta: Double
    public let timestamp: Date
}

public struct BenchmarkResult: Codable, Sendable {
    public let name: String
    public let config: BenchmarkSuite.BenchmarkConfig
    public let measurements: [BenchmarkMeasurement]
    public let averageExecutionTime: TimeInterval
    public let minExecutionTime: TimeInterval
    public let maxExecutionTime: TimeInterval
    public let standardDeviation: TimeInterval
    public let averageMemoryUsage: Int64
    public let peakMemoryUsage: Int64
    public let averageCPUUsage: Double
    public let peakCPUUsage: Double
    public let timestamp: Date
    public let platform: String
    public let deviceModel: String
}

public struct BenchmarkSession: Sendable {
    public let name: String
    public let config: BenchmarkSuite.BenchmarkConfig
    public let startTime: Date
    
    public init(name: String, config: BenchmarkSuite.BenchmarkConfig) {
        self.name = name
        self.config = config
        self.startTime = Date()
    }
}

public struct BenchmarkExport: Codable, Sendable {
    public let exportDate: Date
    public let platform: String
    public let deviceModel: String
    public let results: [BenchmarkResult]
}

// MARK: - Array Extensions

extension Array where Element == TimeInterval {
    var average: TimeInterval {
        guard !isEmpty else { return 0 }
        return reduce(0, +) / TimeInterval(count)
    }
    
    var standardDeviation: TimeInterval {
        guard count > 1 else { return 0 }
        let avg = average
        let variance = map { pow($0 - avg, 2) }.reduce(0, +) / TimeInterval(count - 1)
        return sqrt(variance)
    }
}

extension Array where Element == Int64 {
    var average: Int64 {
        guard !isEmpty else { return 0 }
        return reduce(0, +) / Int64(count)
    }
}

extension Array where Element == Double {
    var average: Double {
        guard !isEmpty else { return 0 }
        return reduce(0, +) / Double(count)
    }
}