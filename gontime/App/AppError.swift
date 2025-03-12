//
//  AppError.swift
//  gontime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@google.com
//

import Foundation

// MARK: - App Error Types

/// Represents various error types that can occur in the application
enum AppError: LocalizedError {

  // MARK: - Error Cases

  /// Authentication and sign-in related errors
  case auth(Error)

  /// Calendar access and data retrieval errors
  case calendar(Error)

  /// Network connectivity and request errors
  case network(Error)

  /// Data parsing and decoding errors
  case decode(Error)

  /// Request formation and validation errors
  case request(Error)

  /// General application errors
  case general(Error)

  // MARK: - LocalizedError Implementation

  /// Provides a user-friendly description of the error
  var errorDescription: String? {
    switch self {
    case .auth(let error):
      return "Authentication failed: \(error.localizedDescription)"

    case .calendar(let error):
      return "Calendar access failed: \(error.localizedDescription)"

    case .network(let error):
      return "Network connection failed: \(error.localizedDescription)"

    case .decode(let error):
      return "Failed to process data: \(error.localizedDescription)"

    case .request(let error):
      return "Request failed: \(error.localizedDescription)"

    case .general(let error):
      return error.localizedDescription
    }
  }
}
