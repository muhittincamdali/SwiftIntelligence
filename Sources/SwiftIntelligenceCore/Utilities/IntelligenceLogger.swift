import Foundation
import os.log

/// Unified logging system for SwiftIntelligence
public final class IntelligenceLogger: Sendable {
    
    // MARK: - Properties
    
    private let subsystem = "com.swiftintelligence"
    private let _loggers = Locked<[String: Logger]>([:])
    private let dateFormatter: DateFormatter
    private let queue = DispatchQueue(label: "com.swiftintelligence.logger", qos: .utility)
    
    // Protected properties
    private let _logLevel = Locked<LogLevel>(.info)
    private let _consoleOutputEnabled = Locked<Bool>(true)
    private let _fileLoggingEnabled = Locked<Bool>(false)
    private let _logFileURL = Locked<URL?>(nil)
    
    /// Current log level
    public var logLevel: LogLevel {
        get { _logLevel.withLock { $0 } }
        set { _logLevel.withLock { $0 = newValue } }
    }
    
    /// Enable console output
    public var consoleOutputEnabled: Bool {
        get { _consoleOutputEnabled.withLock { $0 } }
        set { _consoleOutputEnabled.withLock { $0 = newValue } }
    }
    
    /// Enable file logging
    public var fileLoggingEnabled: Bool {
        get { _fileLoggingEnabled.withLock { $0 } }
        set { 
            _fileLoggingEnabled.withLock { $0 = newValue }
            setupFileLogging()
        }
    }
    
    /// Log file URL
    public var logFileURL: URL? {
        _logFileURL.withLock { $0 }
    }
    
    // MARK: - Initialization
    
    public init() {
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        setupFileLogging()
    }
    
    // MARK: - Logging Methods
    
    public func log(
        _ message: String,
        level: LogLevel = .info,
        category: String = "General",
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) {
        guard level.priority >= logLevel.priority else { return }
        
        queue.async {
            if self.consoleOutputEnabled {
                let logger = self.getLogger(for: category)
                let formattedMessage = self.formatMessage(
                    message,
                    level: level,
                    file: file,
                    line: line,
                    function: function
                )
                
                switch level {
                case .verbose, .debug:
                    logger.debug("\(formattedMessage)")
                case .info:
                    logger.info("\(formattedMessage)")
                case .warning:
                    logger.warning("\(formattedMessage)")
                case .error, .critical:
                    logger.error("\(formattedMessage)")
                }
            }
            
            if self.fileLoggingEnabled {
                self.logToFile(message, level: level, category: category)
            }
        }
    }
    
    public func verbose(_ message: String, category: String = "General", file: String = #file, line: Int = #line, function: String = #function) {
        log(message, level: .verbose, category: category, file: file, line: line, function: function)
    }
    
    public func debug(_ message: String, category: String = "General", file: String = #file, line: Int = #line, function: String = #function) {
        log(message, level: .debug, category: category, file: file, line: line, function: function)
    }
    
    public func info(_ message: String, category: String = "General", file: String = #file, line: Int = #line, function: String = #function) {
        log(message, level: .info, category: category, file: file, line: line, function: function)
    }
    
    public func warning(_ message: String, category: String = "General", file: String = #file, line: Int = #line, function: String = #function) {
        log(message, level: .warning, category: category, file: file, line: line, function: function)
    }
    
    public func error(_ message: String, category: String = "General", file: String = #file, line: Int = #line, function: String = #function) {
        log(message, level: .error, category: category, file: file, line: line, function: function)
    }
    
    public func critical(_ message: String, category: String = "General", file: String = #file, line: Int = #line, function: String = #function) {
        log(message, level: .critical, category: category, file: file, line: line, function: function)
    }
    
    // MARK: - Private Methods
    
    private func getLogger(for category: String) -> Logger {
        _loggers.withLock { dict in
            if let logger = dict[category] {
                return logger
            }
            
            let logger = Logger(subsystem: subsystem, category: category)
            dict[category] = logger
            return logger
        }
    }
    
    private func formatMessage(
        _ message: String,
        level: LogLevel,
        file: String,
        line: Int,
        function: String
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
        
        _logFileURL.withLock { $0 = logsDirectory.appendingPathComponent(fileName) }
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

public enum LogLevel: String, Sendable {
    case verbose
    case debug
    case info
    case warning
    case error
    case critical
    
    var priority: Int {
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
