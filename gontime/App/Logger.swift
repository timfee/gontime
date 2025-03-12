//
//  App/Logger.swift
//  gOnTime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@ (Tim Feeley)
//

import Foundation
import os.log

enum Logger {
  private enum Level: String {
    case debug = "📝"
    case error = "❌"
    case state = "🔄"
    var osLogType: OSLogType {
      switch self {
      case .error: return .error
      case .debug: return .debug
      case .state: return .info
      }
    }
  }
  private static let osLog = OSLog(
    subsystem: Bundle.main.bundleIdentifier ?? "com.timfee.gontime", category: "app")
  static func debug(
    _ message: String,
    function: String = #function,
    file: String = #file
  ) {
    log(.debug, message: message, function: function, file: file)
  }
  static func error(
    _ message: String,
    error: Error? = nil,
    function: String = #function,
    file: String = #file
  ) {
    let fullMessage = error.map { "\(message): \($0)" } ?? message
    log(.error, message: fullMessage, function: function, file: file)
  }
  static func state(
    _ message: String,
    function: String = #function,
    file: String = #file
  ) {
    log(.state, message: message, function: function, file: file)
  }
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
      if level == .error {
        os_log("%{public}@", log: osLog, type: level.osLogType, logMessage)
      }
    #endif
  }
}
