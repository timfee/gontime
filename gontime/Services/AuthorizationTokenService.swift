//
//  AuthorizationTokenService.swift
//  gontime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@google.com
//

import Foundation
import GoogleSignIn

// MARK: - Authorization Token Service

/// Manages OAuth token refresh and session creation for Google Calendar API requests
final class AuthorizationTokenService {

  // MARK: - Public Methods

  /// Creates an authorized URLSession for making API requests
  /// - Returns: URLSession configured with current access token
  /// - Throws: AppError.auth if token refresh fails or no valid token exists
  static func createSession() async throws -> URLSession {
    try await withCheckedThrowingContinuation { continuation in
      // Attempt to refresh the token if needed before creating the session
      GIDSignIn.sharedInstance.currentUser?.refreshTokensIfNeeded { user, error in
        if let error = error {
          continuation.resume(throwing: AppError.auth(error))
          return
        }

        guard let accessToken = user?.accessToken else {
          continuation.resume(
            throwing: AppError.auth(
              NSError(
                domain: "Auth",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "No access token"]
              )
            )
          )
          return
        }

        // Create session with bearer token authorization
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
          "Authorization": "Bearer \(accessToken.tokenString)"
        ]
        let session = URLSession(configuration: config)
        continuation.resume(returning: session)
      }
    }
  }
}
