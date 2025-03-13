//
//  SignedOutUserView.swift
//  gontime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@google.com
//

import SwiftUI

// MARK: - Signed Out User View

/// Displays sign-in prompt for unauthenticated users
struct SignedOutUserView: View {

  // MARK: - Properties

  let handleSignIn: () -> Void

  // MARK: - View Body

  var body: some View {
    HStack {
      Text("Not signed in")
        .foregroundStyle(.secondary)
      Spacer()
      Button("Sign in", action: handleSignIn)
    }
  }
}
