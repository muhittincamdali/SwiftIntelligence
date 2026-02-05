// TimeSeriesEngine.swift
// SwiftIntelligence - Time Series Prediction & Analysis
// Copyright © 2024 Muhittin Camdali. MIT License.

import Foundation
import Accelerate

/// On-device time series forecasting and trend detection engine
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public actor TimeSeriesEngine {
    
    // MARK: - Singleton
    
    public static let shared = TimeSeriesEngine()
    
    // MARK: - Properties
    
    private var seasonalModels: [String: SeasonalModel] = [:]
    private var cache = NSCache<NSString, AnyObject>()
    
    // MARK: - Initialization
    
    private init() {
        cache.countLimit = 50
    }
    
    // MARK: - Forecasting
    
    /// Forecast future values in a time series
    public func forecast(
        _ series: [Double],
        steps: Int
    ) async throws -> ForecastResult {
        
        guard series.count >= 5 else {
            throw TimeSeriesError.insufficientData
        }
        
        guard steps > 0 && steps <= 100 else {
            throw TimeSeriesError.invalidSteps
        }
        
        // Detect seasonality
        let seasonality = detectSeasonality(series)
        
        // Choose forecasting method based on data characteristics
        let predictions: [Double]
        let confidence: Float
        
        if seasonality != nil {
            // Use seasonal decomposition + ARIMA
            let result = seasonalForecast(series, steps: steps, seasonality: seasonality!)
            predictions = result.predictions
            confidence = result.confidence
        } else {
            // Use exponential smoothing
            let result = exponentialSmoothingForecast(series, steps: steps)
            predictions = result.predictions
            confidence = result.confidence
        }
        
        // Calculate confidence intervals
        let (lowerBounds, upperBounds) = calculateConfidenceIntervals(
            predictions: predictions,
            historicalStdDev: standardDeviation(series)
        )
        
        return ForecastResult(
            predictions: predictions,
            lowerBounds: lowerBounds,
            upperBounds: upperBounds,
            confidence: confidence
        )
    }
    
    /// Detect trends in time series data
    public func detectTrends(in series: [Double]) async throws -> TrendResult {
        guard series.count >= 5 else {
            throw TimeSeriesError.insufficientData
        }
        
        // Calculate trend direction and strength
        let (direction, strength) = calculateTrendDirection(series)
        
        // Detect seasonality
        let seasonalityInfo: TrendResult.Seasonality?
        if let detected = detectSeasonality(series) {
            seasonalityInfo = TrendResult.Seasonality(
                period: detected.period,
                strength: detected.strength
            )
        } else {
            seasonalityInfo = nil
        }
        
        return TrendResult(
            direction: direction,
            strength: strength,
            seasonality: seasonalityInfo
        )
    }
    
    // MARK: - Advanced Analysis
    
    /// Decompose time series into trend, seasonal, and residual components
    public func decompose(_ series: [Double]) async throws -> TimeSeriesDecomposition {
        guard series.count >= 10 else {
            throw TimeSeriesError.insufficientData
        }
        
        // Extract trend using moving average
        let windowSize = min(7, series.count / 3)
        let trend = movingAverage(series, window: windowSize)
        
        // Calculate detrended series
        let detrended = zip(series, trend).map { $0 - $1 }
        
        // Detect and extract seasonal component
        var seasonal = [Double](repeating: 0, count: series.count)
        if let seasonality = detectSeasonality(series) {
            seasonal = extractSeasonalComponent(detrended, period: seasonality.period)
        }
        
        // Residual = original - trend - seasonal
        let residual = zip(zip(series, trend), seasonal).map { $0.0 - $0.1 - $1 }
        
        return TimeSeriesDecomposition(
            trend: trend,
            seasonal: seasonal,
            residual: residual
        )
    }
    
    /// Detect change points in time series
    public func detectChangePoints(_ series: [Double]) async throws -> [ChangePoint] {
        guard series.count >= 10 else {
            throw TimeSeriesError.insufficientData
        }
        
        var changePoints: [ChangePoint] = []
        let windowSize = max(5, series.count / 10)
        
        for i in windowSize..<(series.count - windowSize) {
            let leftWindow = Array(series[(i-windowSize)..<i])
            let rightWindow = Array(series[i..<(i+windowSize)])
            
            let leftMean = leftWindow.reduce(0, +) / Double(leftWindow.count)
            let rightMean = rightWindow.reduce(0, +) / Double(rightWindow.count)
            
            let leftStd = standardDeviation(leftWindow)
            let rightStd = standardDeviation(rightWindow)
            
            // T-test for mean difference
            let pooledStd = sqrt((leftStd * leftStd + rightStd * rightStd) / 2)
            let tScore = abs(rightMean - leftMean) / (pooledStd * sqrt(2.0 / Double(windowSize)))
            
            // Significant change point if t-score > threshold
            if tScore > 2.5 {
                let changeType: ChangePointType = rightMean > leftMean ? .increase : .decrease
                
                changePoints.append(ChangePoint(
                    index: i,
                    type: changeType,
                    magnitude: abs(rightMean - leftMean),
                    confidence: Float(min(1.0, tScore / 5.0))
                ))
            }
        }
        
        // Merge nearby change points
        return mergeNearbyChangePoints(changePoints, minDistance: windowSize)
    }
    
    /// Calculate autocorrelation
    public func autocorrelation(_ series: [Double], lag: Int) async throws -> Double {
        guard lag > 0 && lag < series.count else {
            throw TimeSeriesError.invalidLag
        }
        
        let n = series.count
        let mean = series.reduce(0, +) / Double(n)
        
        var numerator: Double = 0
        var denominator: Double = 0
        
        for i in 0..<n {
            denominator += pow(series[i] - mean, 2)
            
            if i >= lag {
                numerator += (series[i] - mean) * (series[i - lag] - mean)
            }
        }
        
        return denominator > 0 ? numerator / denominator : 0
    }
    
    // MARK: - Reset
    
    public func reset() async {
        seasonalModels.removeAll()
        cache.removeAllObjects()
    }
    
    // MARK: - Private Helpers
    
    private func exponentialSmoothingForecast(
        _ series: [Double],
        steps: Int
    ) -> (predictions: [Double], confidence: Float) {
        
        // Double exponential smoothing (Holt's method)
        let alpha: Double = 0.3 // Level smoothing
        let beta: Double = 0.1  // Trend smoothing
        
        var level = series[0]
        var trend = series.count > 1 ? series[1] - series[0] : 0
        
        // Fit model on historical data
        for i in 1..<series.count {
            let prevLevel = level
            level = alpha * series[i] + (1 - alpha) * (level + trend)
            trend = beta * (level - prevLevel) + (1 - beta) * trend
        }
        
        // Generate forecasts
        var predictions: [Double] = []
        for i in 1...steps {
            predictions.append(level + Double(i) * trend)
        }
        
        // Calculate confidence based on fit quality
        var mse: Double = 0
        var fitted = series[0]
        var fittedTrend = series.count > 1 ? series[1] - series[0] : 0
        
        for i in 1..<series.count {
            let prediction = fitted + fittedTrend
            mse += pow(series[i] - prediction, 2)
            
            let prevFitted = fitted
            fitted = alpha * series[i] + (1 - alpha) * (fitted + fittedTrend)
            fittedTrend = beta * (fitted - prevFitted) + (1 - beta) * fittedTrend
        }
        
        mse /= Double(series.count - 1)
        let rmse = sqrt(mse)
        let range = (series.max() ?? 1) - (series.min() ?? 0)
        let confidence = Float(max(0, 1 - rmse / range))
        
        return (predictions, confidence)
    }
    
    private func seasonalForecast(
        _ series: [Double],
        steps: Int,
        seasonality: SeasonalityResult
    ) -> (predictions: [Double], confidence: Float) {
        
        let period = seasonality.period
        
        // Decompose series
        let trend = movingAverage(series, window: period)
        let detrended = zip(series, trend).map { $0 - $1 }
        
        // Calculate seasonal factors
        var seasonalFactors = [Double](repeating: 0, count: period)
        var counts = [Int](repeating: 0, count: period)
        
        for (i, value) in detrended.enumerated() {
            let seasonIndex = i % period
            seasonalFactors[seasonIndex] += value
            counts[seasonIndex] += 1
        }
        
        for i in 0..<period {
            if counts[i] > 0 {
                seasonalFactors[i] /= Double(counts[i])
            }
        }
        
        // Forecast trend
        let (trendPredictions, _) = exponentialSmoothingForecast(trend, steps: steps)
        
        // Add seasonal factors
        var predictions: [Double] = []
        for (i, trendValue) in trendPredictions.enumerated() {
            let seasonIndex = (series.count + i) % period
            predictions.append(trendValue + seasonalFactors[seasonIndex])
        }
        
        return (predictions, seasonality.strength)
    }
    
    private func detectSeasonality(_ series: [Double]) -> SeasonalityResult? {
        guard series.count >= 10 else { return nil }
        
        // Check common periods
        let candidatePeriods = [7, 12, 24, 30, 52, 365]
            .filter { $0 < series.count / 2 }
        
        var bestPeriod = 0
        var bestStrength: Float = 0
        
        for period in candidatePeriods {
            // Calculate autocorrelation at this lag
            let acf = autocorrelationSync(series, lag: period)
            
            if abs(acf) > Double(bestStrength) && abs(acf) > 0.3 {
                bestPeriod = period
                bestStrength = Float(abs(acf))
            }
        }
        
        if bestPeriod > 0 {
            return SeasonalityResult(period: bestPeriod, strength: bestStrength)
        }
        
        return nil
    }
    
    private func autocorrelationSync(_ series: [Double], lag: Int) -> Double {
        guard lag > 0 && lag < series.count else { return 0 }
        
        let n = series.count
        let mean = series.reduce(0, +) / Double(n)
        
        var numerator: Double = 0
        var denominator: Double = 0
        
        for i in 0..<n {
            denominator += pow(series[i] - mean, 2)
            
            if i >= lag {
                numerator += (series[i] - mean) * (series[i - lag] - mean)
            }
        }
        
        return denominator > 0 ? numerator / denominator : 0
    }
    
    private func calculateTrendDirection(_ series: [Double]) -> (TrendResult.TrendDirection, Float) {
        // Linear regression for trend
        let n = Double(series.count)
        let xMean = (n - 1) / 2
        let yMean = series.reduce(0, +) / n
        
        var numerator: Double = 0
        var denominator: Double = 0
        
        for (i, y) in series.enumerated() {
            let x = Double(i)
            numerator += (x - xMean) * (y - yMean)
            denominator += pow(x - xMean, 2)
        }
        
        let slope = denominator > 0 ? numerator / denominator : 0
        
        // Calculate R-squared for strength
        let variance = series.map { pow($0 - yMean, 2) }.reduce(0, +)
        var residuals: Double = 0
        
        for (i, y) in series.enumerated() {
            let predicted = yMean + slope * (Double(i) - xMean)
            residuals += pow(y - predicted, 2)
        }
        
        let rSquared = variance > 0 ? 1 - (residuals / variance) : 0
        let strength = Float(max(0, min(1, rSquared)))
        
        // Calculate volatility
        let volatility = standardDeviation(series) / abs(yMean)
        
        let direction: TrendResult.TrendDirection
        if volatility > 0.3 {
            direction = .volatile
        } else if abs(slope) < 0.01 * yMean {
            direction = .stable
        } else if slope > 0 {
            direction = .increasing
        } else {
            direction = .decreasing
        }
        
        return (direction, strength)
    }
    
    private func movingAverage(_ series: [Double], window: Int) -> [Double] {
        guard window > 0 && window <= series.count else { return series }
        
        var result = [Double](repeating: 0, count: series.count)
        var sum: Double = 0
        
        for i in 0..<series.count {
            sum += series[i]
            
            if i >= window {
                sum -= series[i - window]
            }
            
            let count = min(i + 1, window)
            result[i] = sum / Double(count)
        }
        
        return result
    }
    
    private func extractSeasonalComponent(_ series: [Double], period: Int) -> [Double] {
        var seasonal = [Double](repeating: 0, count: series.count)
        
        // Average for each season
        var seasonalAverages = [Double](repeating: 0, count: period)
        var counts = [Int](repeating: 0, count: period)
        
        for (i, value) in series.enumerated() {
            let seasonIndex = i % period
            seasonalAverages[seasonIndex] += value
            counts[seasonIndex] += 1
        }
        
        for i in 0..<period {
            if counts[i] > 0 {
                seasonalAverages[i] /= Double(counts[i])
            }
        }
        
        // Apply seasonal averages
        for i in 0..<series.count {
            seasonal[i] = seasonalAverages[i % period]
        }
        
        return seasonal
    }
    
    private func calculateConfidenceIntervals(
        predictions: [Double],
        historicalStdDev: Double
    ) -> (lower: [Double], upper: [Double]) {
        
        var lowerBounds: [Double] = []
        var upperBounds: [Double] = []
        
        for (i, prediction) in predictions.enumerated() {
            // Widen confidence interval as we predict further
            let widthMultiplier = 1.0 + 0.1 * Double(i)
            let width = 1.96 * historicalStdDev * widthMultiplier
            
            lowerBounds.append(prediction - width)
            upperBounds.append(prediction + width)
        }
        
        return (lowerBounds, upperBounds)
    }
    
    private func standardDeviation(_ data: [Double]) -> Double {
        let n = Double(data.count)
        let mean = data.reduce(0, +) / n
        let variance = data.map { pow($0 - mean, 2) }.reduce(0, +) / n
        return sqrt(variance)
    }
    
    private func mergeNearbyChangePoints(
        _ points: [ChangePoint],
        minDistance: Int
    ) -> [ChangePoint] {
        
        guard !points.isEmpty else { return [] }
        
        var merged: [ChangePoint] = [points[0]]
        
        for point in points.dropFirst() {
            if let last = merged.last, point.index - last.index < minDistance {
                // Keep the one with higher confidence
                if point.confidence > last.confidence {
                    merged[merged.count - 1] = point
                }
            } else {
                merged.append(point)
            }
        }
        
        return merged
    }
}

// MARK: - Supporting Types

/// Time series decomposition result
public struct TimeSeriesDecomposition: Sendable {
    public let trend: [Double]
    public let seasonal: [Double]
    public let residual: [Double]
}

/// Detected change point
public struct ChangePoint: Sendable {
    public let index: Int
    public let type: ChangePointType
    public let magnitude: Double
    public let confidence: Float
}

/// Change point type
public enum ChangePointType: String, Sendable {
    case increase
    case decrease
    case levelShift
}

/// Seasonality detection result
private struct SeasonalityResult {
    let period: Int
    let strength: Float
}

/// Seasonal model
private struct SeasonalModel {
    let period: Int
    let factors: [Double]
}

/// Time series errors
public enum TimeSeriesError: LocalizedError {
    case insufficientData
    case invalidSteps
    case invalidLag
    case modelNotTrained
    
    public var errorDescription: String? {
        switch self {
        case .insufficientData: return "Insufficient data for time series analysis"
        case .invalidSteps: return "Invalid number of forecast steps"
        case .invalidLag: return "Invalid lag value"
        case .modelNotTrained: return "Model not trained"
        }
    }
}
