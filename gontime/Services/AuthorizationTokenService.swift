//
//  GoogleSessionProvider.swift
//  gontime
//

import Foundation
import GoogleSignIn

/// Service responsible for creating authenticated URLSessions using Google Sign-In tokens
final class AuthorizationTokenService {
    /// Creates a URLSession configured with the current user's access token
    /// - Returns: A configured URLSession with authentication headers
    /// - Throws: AppError.auth if token refresh fails or no access token is available
    static func createSession() async throws -> URLSession {
        try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.currentUser?.refreshTokensIfNeeded { user, error in
                if let error = error {
                    continuation.resume(throwing: AppError.auth(error))
                    return
                }
                
                guard let accessToken = user?.accessToken else {
                    continuation.resume(throwing: AppError.auth(
                        NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "No access token"])
                    ))
                    return
                }
                
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

// End of file
