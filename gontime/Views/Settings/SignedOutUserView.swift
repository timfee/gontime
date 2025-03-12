//
//  SignedOutUserView.swift
//  gOnTime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@ (Tim Feeley)
//

import SwiftUI

struct SignedOutUserView: View {
  let handleSignIn: () -> Void
  var body: some View {
    HStack {
      Text("Not signed in")
        .foregroundStyle(.secondary)
      Spacer()
      Button("Sign in", action: handleSignIn)
    }
  }
}
