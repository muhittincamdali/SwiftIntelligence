import Foundation

/// Centralized error handling system for SwiftIntelligence
@MainActor
public final class ErrorHandler {
    
    // MARK: - Properties
    
    private var errorCallbacks: [(IntelligenceError) -> Void] = []
    private var recoveryStrategies: [String: RecoveryStrategy] = [:]
    private let logger = IntelligenceLogger()
    
    /// Error history
    public private(set) var errorHistory: [ErrorRecord] = []
    
    /// Maximum error history size
    public var maxHistorySize: Int = 100
    
    // MARK: - Error Handling
    
    /// Handle an error
    /// - Parameters:
    ///   - error: Error to handle
    ///   - context: Error context
    ///   - recovery: Recovery strategy
    public func handle(
        _ error: Error,
        context: ErrorContext? = nil,
        recovery: RecoveryStrategy? = nil
    ) {
        let intelligenceError = IntelligenceError(from: error, context: context)
        
        // Log error
        logger.error("Error: \(intelligenceError.description)", category: "ErrorHandler")
        
        // Record error
        recordError(intelligenceError)
        
        // Attempt recovery
        if let strategy = recovery ?? recoveryStrategies[intelligenceError.code] {
            attemptRecovery(for: intelligenceError, using: strategy)
        }
        
        // Notify callbacks
        notifyCallbacks(intelligenceError)
    }
    
    /// Register error callback
    /// - Parameter callback: Callback to execute when error occurs
    public func registerCallback(_ callback: @escaping (IntelligenceError) -> Void) {
        errorCallbacks.append(callback)
    }
    
    /// Register recovery strategy
    /// - Parameters:
    ///   - strategy: Recovery strategy
    ///   - errorCode: Error code to apply strategy to
    public func registerRecoveryStrategy(
        _ strategy: RecoveryStrategy,
        forErrorCode errorCode: String
    ) {
        recoveryStrategies[errorCode] = strategy
    }
    
    /// Clear error history
    public func clearHistory() {
        errorHistory.removeAll()
    }
    
    /// Get errors by severity
    /// - Parameter severity: Error severity
    /// - Returns: Filtered errors
    public func errors(withSeverity severity: ErrorSeverity) -> [ErrorRecord] {
        errorHistory.filter { $0.error.severity == severity }
    }
    
    /// Get errors by module
    /// - Parameter module: Module name
    /// - Returns: Filtered errors
    public func errors(fromModule module: String) -> [ErrorRecord] {
        errorHistory.filter { $0.error.context?.module == module }
    }
    
    // MARK: - Private Methods
    
    private func recordError(_ error: IntelligenceError) {
        let record = ErrorRecord(
            error: error,
            timestamp: Date(),
            recovered: false
        )
        
        errorHistory.append(record)
        
        // Limit history size
        if errorHistory.count > maxHistorySize {
            errorHistory.removeFirst()
        }
    }
    
    private func attemptRecovery(
        for error: IntelligenceError,
        using strategy: RecoveryStrategy
    ) {
        switch strategy {
        case .retry(let attempts, let delay):
            handleRetryRecovery(attempts: attempts, delay: delay, error: error)
            
        case .fallback(let handler):
            handler(error)
            markErrorAsRecovered(error)
            
        case .ignore:
            markErrorAsRecovered(error)
            
        case .escalate:
            escalateError(error)
            
        case .custom(let handler):
            handler(error)
        }
    }
    
    private func handleRetryRecovery(
        attempts: Int,
        delay: TimeInterval,
        error: IntelligenceError
    ) {
        Task {
            for attempt in 1...attempts {
                logger.info("Retry attempt \(attempt) for error: \(error.code)")
                
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                
                // Here you would retry the operation
                // For now, we'll just mark as recovered after attempts
                if attempt == attempts {
                    markErrorAsRecovered(error)
                }
            }
        }
    }
    
    private func markErrorAsRecovered(_ error: IntelligenceError) {
        if let index = errorHistory.firstIndex(where: { $0.error.id == error.id }) {
            errorHistory[index].recovered = true
        }
    }
    
    private func escalateError(_ error: IntelligenceError) {
        logger.critical("Escalated error: \(error.description)", category: "ErrorHandler")
        // Here you would implement actual escalation logic
    }
    
    private func notifyCallbacks(_ error: IntelligenceError) {
        errorCallbacks.forEach { callback in
            callback(error)
        }
    }
}

// MARK: - Supporting Types

/// Intelligence-specific error type
public struct IntelligenceError: Error, Sendable {
    public let id: UUID
    public let code: String
    public let message: String
    public let underlyingError: Error?
    public let severity: ErrorSeverity
    public let context: ErrorContext?
    public let timestamp: Date
    
    public var description: String {
        var desc = "[\(severity.rawValue)] \(code): \(message)"
        if let context = context {
            desc += " (Module: \(context.module), Operation: \(context.operation ?? "Unknown"))"
        }
        return desc
    }
    
    public init(
        code: String,
        message: String,
        underlyingError: Error? = nil,
        severity: ErrorSeverity = .medium,
        context: ErrorContext? = nil
    ) {
        self.id = UUID()
        self.code = code
        self.message = message
        self.underlyingError = underlyingError
        self.severity = severity
        self.context = context
        self.timestamp = Date()
    }
    
    public init(from error: Error, context: ErrorContext? = nil) {
        if let intelligenceError = error as? IntelligenceError {
            self.id = intelligenceError.id
            self.code = intelligenceError.code
            self.message = intelligenceError.message
            self.underlyingError = intelligenceError.underlyingError
            self.severity = intelligenceError.severity
            self.context = intelligenceError.context
            self.timestamp = intelligenceError.timestamp
        } else {
            self.id = UUID()
            self.code = "UNKNOWN"
            self.message = error.localizedDescription
            self.underlyingError = error
            self.severity = .medium
            self.context = context
            self.timestamp = Date()
        }
    }
}

/// Error severity levels
public enum ErrorSeverity: String, Sendable {
    case low
    case medium
    case high
    case critical
}

/// Error context information
public struct ErrorContext: Sendable {
    public let module: String
    public let operation: String?
    public let metadata: [String: String]
    
    public init(
        module: String,
        operation: String? = nil,
        metadata: [String: String] = [:]
    ) {
        self.module = module
        self.operation = operation
        self.metadata = metadata
    }
}

/// Error record for history
public struct ErrorRecord: Sendable {
    public let error: IntelligenceError
    public let timestamp: Date
    public var recovered: Bool
}

/// Recovery strategy for errors
public enum RecoveryStrategy: Sendable {
    case retry(attempts: Int, delay: TimeInterval)
    case fallback(handler: @Sendable (IntelligenceError) -> Void)
    case ignore
    case escalate
    case custom(handler: @Sendable (IntelligenceError) -> Void)
}

// MARK: - Common Error Codes

public extension IntelligenceError {
    static let configurationError = "CONFIGURATION_ERROR"
    static let initializationError = "INITIALIZATION_ERROR"
    static let validationError = "VALIDATION_ERROR"
    static let processingError = "PROCESSING_ERROR"
    static let networkError = "NETWORK_ERROR"
    static let memoryError = "MEMORY_ERROR"
    static let timeoutError = "TIMEOUT_ERROR"
    static let unsupportedError = "UNSUPPORTED_ERROR"
    static let authenticationError = "AUTHENTICATION_ERROR"
    static let authorizationError = "AUTHORIZATION_ERROR"
}