//
//  GoogleSessionProvider.swift
//  gontime
//

import Foundation
import GoogleSignIn

enum GoogleSessionProvider {
    static func createSession() async throws -> URLSessionProtocol {
        try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.currentUser?.refreshTokensIfNeeded { user, error in
                if let error = error {
                    continuation.resume(throwing: CalendarServiceError.auth(error))
                    return
                }
                
                guard let token = user?.accessToken.tokenString else {
                    continuation.resume(throwing: CalendarServiceError.auth(
                        NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "No access token"])
                    ))
                    return
                }
                
                let config = URLSessionConfiguration.default
                config.httpAdditionalHeaders = [
                    "Authorization": "Bearer \(token)"
                ]
                let session = URLSession(configuration: config)
                continuation.resume(returning: session)
            }
        }
    }
}

// End of file
