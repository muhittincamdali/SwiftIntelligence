import Foundation
import os.log

/// Unified logging system for SwiftIntelligence
public final class IntelligenceLogger: @unchecked Sendable {
    
    // MARK: - Properties
    
    private let subsystem = "com.swiftintelligence"
    private var loggers: [String: Logger] = [:]
    private let dateFormatter: DateFormatter
    private let queue = DispatchQueue(label: "com.swiftintelligence.logger", qos: .utility)
    
    /// Current log level
    public var logLevel: LogLevel = .info
    
    /// Enable console output
    public var consoleOutputEnabled: Bool = true
    
    /// Enable file logging
    public var fileLoggingEnabled: Bool = false
    
    /// Log file URL
    public private(set) var logFileURL: URL?
    
    // MARK: - Initialization
    
    public init() {
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        setupFileLogging()
    }
    
    // MARK: - Logging Methods
    
    /// Log a message
    /// - Parameters:
    ///   - message: Message to log
    ///   - level: Log level
    ///   - category: Category for grouping logs
    ///   - file: Source file
    ///   - function: Source function
    ///   - line: Source line
    public func log(
        _ message: String,
        level: LogLevel = .info,
        category: String = "General",
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard level >= logLevel else { return }
        
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let logger = self.getLogger(for: category)
            let formattedMessage = self.formatMessage(
                message,
                level: level,
                file: file,
                function: function,
                line: line
            )
            
            // Log to os.log
            switch level {
            case .verbose:
                logger.debug("\(formattedMessage)")
            case .debug:
                logger.debug("\(formattedMessage)")
            case .info:
                logger.info("\(formattedMessage)")
            case .warning:
                logger.warning("\(formattedMessage)")
            case .error:
                logger.error("\(formattedMessage)")
            case .critical:
                logger.critical("\(formattedMessage)")
            }
            
            // Log to console if enabled
            if self.consoleOutputEnabled {
                print("[\(category)] \(formattedMessage)")
            }
            
            // Log to file if enabled
            if self.fileLoggingEnabled {
                self.logToFile(formattedMessage, level: level, category: category)
            }
        }
    }
    
    /// Log verbose message
    public func verbose(_ message: String, category: String = "General") {
        log(message, level: .verbose, category: category)
    }
    
    /// Log debug message
    public func debug(_ message: String, category: String = "General") {
        log(message, level: .debug, category: category)
    }
    
    /// Log info message
    public func info(_ message: String, category: String = "General") {
        log(message, level: .info, category: category)
    }
    
    /// Log warning message
    public func warning(_ message: String, category: String = "General") {
        log(message, level: .warning, category: category)
    }
    
    /// Log error message
    public func error(_ message: String, category: String = "General") {
        log(message, level: .error, category: category)
    }
    
    /// Log critical message
    public func critical(_ message: String, category: String = "General") {
        log(message, level: .critical, category: category)
    }
    
    /// Log error with details
    public func logError(
        _ error: Error,
        message: String? = nil,
        category: String = "Error"
    ) {
        let errorMessage = message ?? "Error occurred"
        let fullMessage = "\(errorMessage): \(error.localizedDescription)"
        log(fullMessage, level: .error, category: category)
    }
    
    /// Log performance metrics
    public func logPerformance(
        operation: String,
        duration: TimeInterval,
        category: String = "Performance"
    ) {
        let message = String(format: "%@ completed in %.3f seconds", operation, duration)
        log(message, level: .debug, category: category)
    }
    
    // MARK: - Private Methods
    
    private func getLogger(for category: String) -> Logger {
        if let logger = loggers[category] {
            return logger
        }
        
        let logger = Logger(subsystem: subsystem, category: category)
        loggers[category] = logger
        return logger
    }
    
    private func formatMessage(
        _ message: String,
        level: LogLevel,
        file: String,
        function: String,
        line: Int
    ) -> String {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let timestamp = dateFormatter.string(from: Date())
        
        return "[\(timestamp)] [\(level.rawValue.uppercased())] [\(fileName):\(line)] \(function) - \(message)"
    }
    
    private func setupFileLogging() {
        guard fileLoggingEnabled else { return }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let logsDirectory = documentsPath.appendingPathComponent("SwiftIntelligence/Logs")
        
        try? FileManager.default.createDirectory(at: logsDirectory, withIntermediateDirectories: true)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let fileName = "swiftintelligence-\(dateFormatter.string(from: Date())).log"
        
        logFileURL = logsDirectory.appendingPathComponent(fileName)
    }
    
    private func logToFile(_ message: String, level: LogLevel, category: String) {
        guard let logFileURL = logFileURL else { return }
        
        let logEntry = "[\(category)] \(message)\n"
        
        if let data = logEntry.data(using: .utf8) {
            if FileManager.default.fileExists(atPath: logFileURL.path) {
                if let fileHandle = try? FileHandle(forWritingTo: logFileURL) {
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data)
                    fileHandle.closeFile()
                }
            } else {
                try? data.write(to: logFileURL)
            }
        }
    }
}

// MARK: - Supporting Types

/// Log level enumeration
public enum LogLevel: String, Comparable, Sendable {
    case verbose
    case debug
    case info
    case warning
    case error
    case critical
    
    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.severity < rhs.severity
    }
    
    private var severity: Int {
        switch self {
        case .verbose: return 0
        case .debug: return 1
        case .info: return 2
        case .warning: return 3
        case .error: return 4
        case .critical: return 5
        }
    }
}