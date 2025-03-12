import Foundation
import os.log

/// A type-safe logging utility that provides structured logging with file and function context.
/// In debug builds, all messages are printed to console.
/// In release builds, errors are logged to the system log.
enum Logger {
    /// Log level to categorize messages
    private enum Level: String {
        case debug = "📝"
        case error = "❌"
        case state = "🔄"
        
        /// The corresponding log type for system logging
        var osLogType: OSLogType {
            switch self {
                case .error: return .error
                case .debug: return .debug
                case .state: return .info
            }
        }
    }
    
    // MARK: - Private Properties
    
    /// System logger instance for release builds
    private static let osLog = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.timfee.gontime", category: "app")
    
    // MARK: - Public Logging Methods
    
    /// Logs debug information during development
    /// - Parameters:
    ///   - message: The message to log
    ///   - function: The calling function (auto-filled)
    ///   - file: The source file (auto-filled)
    static func debug(
        _ message: String,
        function: String = #function,
        file: String = #file
    ) {
        log(.debug, message: message, function: function, file: file)
    }
    
    /// Logs error information with optional Error object
    /// - Parameters:
    ///   - message: The error message
    ///   - error: Optional Error object
    ///   - function: The calling function (auto-filled)
    ///   - file: The source file (auto-filled)
    static func error(
        _ message: String,
        error: Error? = nil,
        function: String = #function,
        file: String = #file
    ) {
        let fullMessage = error.map { "\(message): \($0)" } ?? message
        log(.error, message: fullMessage, function: function, file: file)
    }
    
    /// Logs state changes for debugging
    /// - Parameters:
    ///   - message: The state change message
    ///   - function: The calling function (auto-filled)
    ///   - file: The source file (auto-filled)
    static func state(
        _ message: String,
        function: String = #function,
        file: String = #file
    ) {
        log(.state, message: message, function: function, file: file)
    }
    
    // MARK: - Private Implementation
    
    /// Central logging function that handles all log types
    private static func log(
        _ level: Level,
        message: String,
        function: String,
        file: String
    ) {
        let filename = (file as NSString).lastPathComponent
        let logMessage = "[\(filename):\(function)] \(message)"
        
#if DEBUG
        print("\(level.rawValue) \(logMessage)")
#else
        // In release builds, only log errors to system log
        if level == .error {
            os_log("%{public}@", log: osLog, type: level.osLogType, logMessage)
        }
#endif
    }
}
