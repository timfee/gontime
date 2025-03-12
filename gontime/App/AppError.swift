//
//  App/AppError.swift
//  gOnTime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@ (Tim Feeley)
//

import Foundation

enum AppError: LocalizedError {
  case auth(Error)
  case calendar(Error)
  case network(Error)
  case decode(Error)
  case request(Error)
  case general(Error)
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
