//
//  Services/AuthenticationService.swift
//  gOnTime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@ (Tim Feeley)
//

import Foundation
import GoogleSignIn

final class AuthenticationService {
    // MARK: - Constants
    private let calendarScope =
        "https://www.googleapis.com/auth/calendar.readonly"

    // MARK: - Authentication
    func signIn(completion: @escaping (Result<GIDGoogleUser, Error>) -> Void) {
        guard let presentingWindow = NSApplication.shared.windows.first else {
            completion(
                .failure(AppError.general("No presenting window found!")))
            return
        }

        GIDSignIn.sharedInstance.signIn(
            withPresenting: presentingWindow,
            hint: nil,
            additionalScopes: [calendarScope]
        ) { result, error in
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

            completion(.success(result.user))
        }
    }
}
