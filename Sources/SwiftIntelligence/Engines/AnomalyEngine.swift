// AnomalyEngine.swift
// SwiftIntelligence - AI-Powered Anomaly Detection
// Copyright © 2024 Muhittin Camdali. MIT License.

import Foundation
import Accelerate

/// On-device anomaly detection engine using statistical and ML methods
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public actor AnomalyEngine {
    
    // MARK: - Singleton
    
    public static let shared = AnomalyEngine()
    
    // MARK: - Properties
    
    private var baselineStats: [String: BaselineStatistics] = [:]
    private var isolationForest: IsolationForest?
    private let defaultThreshold: Float = 2.5 // Z-score threshold
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Anomaly Detection
    
    /// Detect anomalies in a data array
    public func detect(in data: [Double]) async throws -> [Anomaly] {
        guard data.count >= 3 else {
            throw AnomalyError.insufficientData
        }
        
        var anomalies: [Anomaly] = []
        
        // Calculate statistics
        let stats = calculateStatistics(data)
        
        for (index, value) in data.enumerated() {
            // Z-score method
            let zScore = abs(value - stats.mean) / stats.stdDev
            
            if zScore > Double(defaultThreshold) {
                let anomalyType = determineAnomalyType(
                    value: value,
                    index: index,
                    data: data,
                    mean: stats.mean
                )
                
                let anomaly = Anomaly(
                    index: index,
                    value: value,
                    score: Float(zScore / 5.0), // Normalize to 0-1
                    type: anomalyType
                )
                anomalies.append(anomaly)
            }
        }
        
        // Also check for pattern anomalies
        let patternAnomalies = detectPatternAnomalies(data, stats: stats)
        anomalies.append(contentsOf: patternAnomalies)
        
        return anomalies.sorted { $0.score > $1.score }
    }
    
    /// Check if a single value is anomalous
    public func isAnomalous(
        _ value: Double,
        baseline: [Double]
    ) async throws -> (isAnomaly: Bool, score: Float) {
        
        guard baseline.count >= 3 else {
            throw AnomalyError.insufficientData
        }
        
        let stats = calculateStatistics(baseline)
        let zScore = abs(value - stats.mean) / stats.stdDev
        
        let isAnomaly = zScore > Double(defaultThreshold)
        let score = Float(min(1.0, zScore / 5.0))
        
        return (isAnomaly, score)
    }
    
    /// Detect anomalies using Isolation Forest algorithm
    public func detectWithIsolationForest(
        data: [[Double]],
        contamination: Float = 0.1
    ) async throws -> [Int] {
        
        guard data.count >= 10 else {
            throw AnomalyError.insufficientData
        }
        
        // Train isolation forest
        let forest = IsolationForest(
            numTrees: 100,
            sampleSize: min(256, data.count),
            contamination: contamination
        )
        
        forest.fit(data)
        self.isolationForest = forest
        
        // Predict anomalies
        let predictions = forest.predict(data)
        
        return predictions.enumerated()
            .filter { $0.element }
            .map { $0.offset }
    }
    
    /// Update baseline with new data
    public func updateBaseline(
        identifier: String,
        data: [Double]
    ) async {
        let stats = calculateStatistics(data)
        baselineStats[identifier] = stats
    }
    
    /// Check value against stored baseline
    public func checkAgainstBaseline(
        identifier: String,
        value: Double
    ) async throws -> (isAnomaly: Bool, score: Float) {
        
        guard let stats = baselineStats[identifier] else {
            throw AnomalyError.baselineNotFound
        }
        
        let zScore = abs(value - stats.mean) / stats.stdDev
        let isAnomaly = zScore > Double(defaultThreshold)
        let score = Float(min(1.0, zScore / 5.0))
        
        return (isAnomaly, score)
    }
    
    // MARK: - Specialized Anomaly Detection
    
    /// Detect sudden spikes in data
    public func detectSpikes(
        in data: [Double],
        sensitivity: Float = 1.0
    ) async throws -> [Anomaly] {
        
        guard data.count >= 5 else {
            throw AnomalyError.insufficientData
        }
        
        var anomalies: [Anomaly] = []
        let adjustedThreshold = defaultThreshold / sensitivity
        
        for i in 2..<(data.count - 2) {
            let localMean = (data[i-2] + data[i-1] + data[i+1] + data[i+2]) / 4.0
            let deviation = abs(data[i] - localMean)
            
            let localVariance = [data[i-2], data[i-1], data[i+1], data[i+2]]
                .map { pow($0 - localMean, 2) }
                .reduce(0, +) / 4.0
            let localStdDev = sqrt(localVariance)
            
            let localZScore = localStdDev > 0 ? deviation / localStdDev : 0
            
            if localZScore > Double(adjustedThreshold) {
                let type: Anomaly.AnomalyType = data[i] > localMean ? .spike : .drop
                
                anomalies.append(Anomaly(
                    index: i,
                    value: data[i],
                    score: Float(min(1.0, localZScore / 5.0)),
                    type: type
                ))
            }
        }
        
        return anomalies
    }
    
    /// Detect trend breaks
    public func detectTrendBreaks(
        in data: [Double],
        windowSize: Int = 10
    ) async throws -> [Anomaly] {
        
        guard data.count >= windowSize * 2 else {
            throw AnomalyError.insufficientData
        }
        
        var anomalies: [Anomaly] = []
        
        for i in windowSize..<(data.count - windowSize) {
            let leftWindow = Array(data[(i-windowSize)..<i])
            let rightWindow = Array(data[i..<(i+windowSize)])
            
            let leftTrend = calculateTrend(leftWindow)
            let rightTrend = calculateTrend(rightWindow)
            
            let trendChange = abs(rightTrend - leftTrend)
            
            // Significant trend change
            if trendChange > 0.5 {
                anomalies.append(Anomaly(
                    index: i,
                    value: data[i],
                    score: Float(min(1.0, trendChange)),
                    type: .pattern
                ))
            }
        }
        
        return anomalies
    }
    
    // MARK: - Reset
    
    public func reset() async {
        baselineStats.removeAll()
        isolationForest = nil
    }
    
    // MARK: - Private Helpers
    
    private func calculateStatistics(_ data: [Double]) -> BaselineStatistics {
        let n = Double(data.count)
        let mean = data.reduce(0, +) / n
        
        let variance = data.map { pow($0 - mean, 2) }.reduce(0, +) / n
        let stdDev = sqrt(variance)
        
        let sorted = data.sorted()
        let median = sorted.count % 2 == 0
            ? (sorted[sorted.count/2 - 1] + sorted[sorted.count/2]) / 2
            : sorted[sorted.count/2]
        
        let q1 = sorted[sorted.count / 4]
        let q3 = sorted[(sorted.count * 3) / 4]
        let iqr = q3 - q1
        
        return BaselineStatistics(
            mean: mean,
            stdDev: max(stdDev, 0.001), // Prevent division by zero
            median: median,
            iqr: iqr,
            min: sorted.first ?? 0,
            max: sorted.last ?? 0
        )
    }
    
    private func determineAnomalyType(
        value: Double,
        index: Int,
        data: [Double],
        mean: Double
    ) -> Anomaly.AnomalyType {
        
        if value > mean {
            // Check if it's a spike (sudden increase)
            if index > 0 && index < data.count - 1 {
                let prevDiff = value - data[index - 1]
                let nextDiff = value - data[index + 1]
                
                if prevDiff > 0 && nextDiff > 0 {
                    return .spike
                }
            }
            return .outlier
        } else {
            // Check if it's a drop (sudden decrease)
            if index > 0 && index < data.count - 1 {
                let prevDiff = data[index - 1] - value
                let nextDiff = data[index + 1] - value
                
                if prevDiff > 0 && nextDiff > 0 {
                    return .drop
                }
            }
            return .outlier
        }
    }
    
    private func detectPatternAnomalies(
        _ data: [Double],
        stats: BaselineStatistics
    ) -> [Anomaly] {
        
        var anomalies: [Anomaly] = []
        
        // Detect consecutive anomalous values (pattern break)
        var consecutiveCount = 0
        var consecutiveStart = 0
        let threshold = stats.mean + 1.5 * stats.stdDev
        
        for (index, value) in data.enumerated() {
            if value > threshold || value < stats.mean - 1.5 * stats.stdDev {
                if consecutiveCount == 0 {
                    consecutiveStart = index
                }
                consecutiveCount += 1
            } else {
                if consecutiveCount >= 3 {
                    // Mark as pattern anomaly
                    anomalies.append(Anomaly(
                        index: consecutiveStart,
                        value: data[consecutiveStart],
                        score: Float(consecutiveCount) / 10.0,
                        type: .pattern
                    ))
                }
                consecutiveCount = 0
            }
        }
        
        return anomalies
    }
    
    private func calculateTrend(_ data: [Double]) -> Double {
        guard data.count >= 2 else { return 0 }
        
        let n = Double(data.count)
        let xMean = (n - 1) / 2
        let yMean = data.reduce(0, +) / n
        
        var numerator: Double = 0
        var denominator: Double = 0
        
        for (i, y) in data.enumerated() {
            let x = Double(i)
            numerator += (x - xMean) * (y - yMean)
            denominator += pow(x - xMean, 2)
        }
        
        return denominator > 0 ? numerator / denominator : 0
    }
}

// MARK: - Baseline Statistics

private struct BaselineStatistics {
    let mean: Double
    let stdDev: Double
    let median: Double
    let iqr: Double
    let min: Double
    let max: Double
}

// MARK: - Isolation Forest

private class IsolationForest {
    private let numTrees: Int
    private let sampleSize: Int
    private let contamination: Float
    private var trees: [IsolationTree] = []
    private var threshold: Double = 0
    
    init(numTrees: Int, sampleSize: Int, contamination: Float) {
        self.numTrees = numTrees
        self.sampleSize = sampleSize
        self.contamination = contamination
    }
    
    func fit(_ data: [[Double]]) {
        let maxDepth = Int(ceil(log2(Double(sampleSize))))
        
        trees = (0..<numTrees).map { _ in
            let sample = data.shuffled().prefix(sampleSize)
            let tree = IsolationTree(maxDepth: maxDepth)
            tree.fit(Array(sample))
            return tree
        }
        
        // Calculate threshold based on contamination
        let scores = data.map { anomalyScore($0) }
        let sortedScores = scores.sorted(by: >)
        let cutoffIndex = Int(Float(sortedScores.count) * contamination)
        threshold = sortedScores[min(cutoffIndex, sortedScores.count - 1)]
    }
    
    func predict(_ data: [[Double]]) -> [Bool] {
        return data.map { anomalyScore($0) > threshold }
    }
    
    private func anomalyScore(_ point: [Double]) -> Double {
        guard !trees.isEmpty else { return 0 }
        
        let avgPathLength = trees.map { $0.pathLength(point) }.reduce(0, +) / Double(trees.count)
        let c = cFactor(Double(sampleSize))
        
        return pow(2, -avgPathLength / c)
    }
    
    private func cFactor(_ n: Double) -> Double {
        if n <= 1 { return 0 }
        return 2 * (log(n - 1) + 0.5772156649) - (2 * (n - 1) / n)
    }
}

private class IsolationTree {
    private var root: IsolationNode?
    private let maxDepth: Int
    
    init(maxDepth: Int) {
        self.maxDepth = maxDepth
    }
    
    func fit(_ data: [[Double]]) {
        root = buildTree(data, depth: 0)
    }
    
    func pathLength(_ point: [Double]) -> Double {
        return pathLength(point, node: root, depth: 0)
    }
    
    private func buildTree(_ data: [[Double]], depth: Int) -> IsolationNode? {
        guard !data.isEmpty else { return nil }
        
        if depth >= maxDepth || data.count <= 1 {
            return IsolationNode(size: data.count)
        }
        
        let numFeatures = data[0].count
        let featureIndex = Int.random(in: 0..<numFeatures)
        
        let values = data.map { $0[featureIndex] }
        guard let minVal = values.min(), let maxVal = values.max(), minVal < maxVal else {
            return IsolationNode(size: data.count)
        }
        
        let splitValue = Double.random(in: minVal...maxVal)
        
        let leftData = data.filter { $0[featureIndex] < splitValue }
        let rightData = data.filter { $0[featureIndex] >= splitValue }
        
        let node = IsolationNode(
            featureIndex: featureIndex,
            splitValue: splitValue,
            left: buildTree(leftData, depth: depth + 1),
            right: buildTree(rightData, depth: depth + 1)
        )
        
        return node
    }
    
    private func pathLength(_ point: [Double], node: IsolationNode?, depth: Double) -> Double {
        guard let node = node else { return depth }
        
        if node.isLeaf {
            return depth + cFactor(Double(node.size))
        }
        
        if point[node.featureIndex] < node.splitValue {
            return pathLength(point, node: node.left, depth: depth + 1)
        } else {
            return pathLength(point, node: node.right, depth: depth + 1)
        }
    }
    
    private func cFactor(_ n: Double) -> Double {
        if n <= 1 { return 0 }
        return 2 * (log(n - 1) + 0.5772156649) - (2 * (n - 1) / n)
    }
}

private class IsolationNode {
    let featureIndex: Int
    let splitValue: Double
    let left: IsolationNode?
    let right: IsolationNode?
    let size: Int
    
    var isLeaf: Bool { left == nil && right == nil }
    
    init(featureIndex: Int = 0, splitValue: Double = 0, left: IsolationNode? = nil, right: IsolationNode? = nil) {
        self.featureIndex = featureIndex
        self.splitValue = splitValue
        self.left = left
        self.right = right
        self.size = 1
    }
    
    init(size: Int) {
        self.featureIndex = 0
        self.splitValue = 0
        self.left = nil
        self.right = nil
        self.size = size
    }
}

// MARK: - Anomaly Errors

public enum AnomalyError: LocalizedError {
    case insufficientData
    case baselineNotFound
    case modelNotTrained
    
    public var errorDescription: String? {
        switch self {
        case .insufficientData: return "Insufficient data for anomaly detection"
        case .baselineNotFound: return "Baseline not found for identifier"
        case .modelNotTrained: return "Anomaly model not trained"
        }
    }
}
