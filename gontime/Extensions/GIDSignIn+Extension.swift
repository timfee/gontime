import GoogleSignIn

extension GIDSignIn {
    /// Asynchronously restores the previous sign-in state.
    /// - Returns: The previously signed-in user
    /// - Throws: AppError.auth with the underlying authentication error
    @MainActor
    func restorePreviousSignInAsync() async throws -> GIDGoogleUser {
        try await withCheckedThrowingContinuation { continuation in
            self.restorePreviousSignIn { user, error in
                if let error = error {
                    continuation.resume(throwing: AppError.auth(error))
                    return
                }
                
                guard let user = user else {
                    let error = NSError(
                        domain: "com.gontime",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "No user found during sign-in restoration"]
                    )
                    continuation.resume(throwing: AppError.auth(error))
                    return
                }
                
                continuation.resume(returning: user)
            }
        }
    }
}
