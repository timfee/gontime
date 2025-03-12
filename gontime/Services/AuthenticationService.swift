import Foundation
import GoogleSignIn

final class AuthenticationService {
    // MARK: - Constants
    private let calendarScope =
    "https://www.googleapis.com/auth/calendar.readonly"
    
    // MARK: - Authentication
    @MainActor
    func signIn() async throws -> GIDGoogleUser {
        guard let keyWindow = NSApplication.shared.keyWindow else {
            throw AppError.auth(makeError(
                code: -1,
                description: "No window available for sign in"
            ))
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.signIn(
                withPresenting: keyWindow
            ) { result, error in
                if let error = error {
                    continuation.resume(throwing: AppError.auth(error))
                    return
                }
                
                guard let user = result?.user else {
                    continuation.resume(throwing: AppError.auth(self.makeError(
                        code: -1,
                        description: "Failed to get user from sign in"
                    )))
                    return
                }
                
                continuation.resume(returning: user)
            }
        }
    }
    
    // MARK: - Private Helpers
    
    private func makeError(code: Int, description: String) -> NSError {
        NSError(
            domain: "Auth",
            code: code,
            userInfo: [NSLocalizedDescriptionKey: description]
        )
    }
}
