import Foundation
import GoogleSignIn

final class AuthenticationService {
    // MARK: - Constants
    private let calendarScope =
        "https://www.googleapis.com/auth/calendar.readonly"

    // MARK: - Authentication
    /// Signs in the user with Google Sign In.
    ///
    /// - Parameters:
    ///   - completion: Completion handler with a `Result` indicating success or failure.
    func signIn(completion: @escaping (Result<GIDGoogleUser, Error>) -> Void) {
        // Check for a presenting window
        guard let presentingWindow = NSApplication.shared.windows.first else {
            completion(
                .failure(AppError.general("No presenting window found!")))
            return
        }

        // Initiate sign in with the presenting window
        GIDSignIn.sharedInstance.signIn(
            withPresenting: presentingWindow,
            hint: nil,
            additionalScopes: [calendarScope]
        ) { result, error in
            // Check if the error is a cancelation error
            if let error = error as NSError?,
                error.code == GIDSignInError.canceled.rawValue
            {
                completion(
                    .failure(
                        AppError.auth(
                            NSError(
                                domain: "SignIn",
                                code: -2,
                                userInfo: [
                                    NSLocalizedDescriptionKey:
                                        "Sign-in was cancelled by the user."
                                ]
                            ))))
                return
            }

            // Check if the result is valid and has granted scopes
            guard let result = result,
                let grantedScopes = result.user.grantedScopes,
                grantedScopes.contains(self.calendarScope)
            else {
                completion(
                    .failure(
                        AppError.auth(
                            NSError(
                                domain: "SignIn",
                                code: -3,
                                userInfo: [
                                    NSLocalizedDescriptionKey:
                                        "Calendar permission was not granted."
                                ]
                            ))))
                return
            }

            // Completion handler
            completion(.success(result.user))
        }
    }
    // MARK: - Constants
    private let calendarScope =
        "https://www.googleapis.com/auth/calendar.readonly"
    
    // MARK: - Authentication Service
    /// The `AuthenticationService` class handles the Google sign in process.
    ///
    /// - Note: This class requires Google Sign In to work.
}
