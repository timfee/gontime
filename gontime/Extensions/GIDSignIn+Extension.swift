//
//  Extensions/GIDSignIn+Extension.swift
//  gOnTime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@ (Tim Feeley)
//

import GoogleSignIn

extension GIDSignIn {
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
