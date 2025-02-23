//
//  GoogleSignInAuthenticator.swift
//  gontime
//
//  Created by Tim Feeley on 2/20/25.
//

import Foundation
import GoogleSignIn

final class GoogleSignInAuthenticator {
    func signIn(completion: @escaping (Result<GIDGoogleUser, Error>) -> Void) {
        guard let presentingWindow = NSApplication.shared.windows.first else {
            completion(.failure(NSError(domain: "SignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "No presenting window found!"])))
            return
        }
        
        let additionalScopes = ["https://www.googleapis.com/auth/calendar.readonly"]
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingWindow, hint: nil, additionalScopes: additionalScopes) {
 result,
 error in
            
            // ✅ Handle explicit Google Sign-In cancellations
            if let error = error as NSError?,
 error.code == GIDSignInError.canceled.rawValue {
                completion(.failure(NSError(domain: "SignIn", code: -2, userInfo: [NSLocalizedDescriptionKey: "Sign-in was cancelled by the user."])))
                return
            }
            
            // ✅ Handle silent cancellation (result and error are nil)
            if result == nil {
                completion(.failure(NSError(domain: "SignIn", code: -3, userInfo: [NSLocalizedDescriptionKey: "Sign-in was cancelled or failed."])))
                return
            }
            
            guard let result = result else {
                completion(
                    .failure(
                        NSError(
                            domain: "SignIn",
                            code: -4,
                            userInfo: [NSLocalizedDescriptionKey: "\(error?.localizedDescription ?? "Unknown error")"]
                        )
                    )
                )
                return
            }
            
            if let grantedScopes = result.user.grantedScopes,
 grantedScopes.contains("https://www.googleapis.com/auth/calendar.readonly") {
                completion(.success(result.user))
            } else {
                completion(.failure(NSError(domain: "SignIn", code: -5, userInfo: [NSLocalizedDescriptionKey: "Google Calendar permission was not granted."])))
            }
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
    }
    
    func disconnect(completion: @escaping (Error?) -> Void) {
        GIDSignIn.sharedInstance.disconnect { error in
            completion(error)
        }
    }
}
