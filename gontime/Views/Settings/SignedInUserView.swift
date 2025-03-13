//
//  SignedInUserView.swift
//  gontime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@google.com
//

import GoogleSignIn
import SwiftUI

// MARK: - Signed In User View

/// Displays authenticated user information and sign-out option
struct SignedInUserView: View {

  // MARK: - Properties

  let user: GIDGoogleUser
  let handleSignOut: () -> Void

  // MARK: - View Body

  var body: some View {
    HStack {
      userAvatar
      userInfo
      Spacer()
      signOutButton
    }
  }

  // MARK: - Private Views

  /// User avatar with async loading and fallback

  @ViewBuilder
  private var userAvatar: some View {
    Group {
      if let imageURL = user.profile?.imageURL(withDimension: 64) {
        AsyncImage(url: imageURL) { image in
          image.resizable()
            .aspectRatio(contentMode: .fit)
            .clipShape(Circle())
        } placeholder: {
          defaultAvatar
        }
      } else {
        defaultAvatar
      }
    }
    .frame(width: 40, height: 40)
  }

  /// Default avatar for when user image is unavailable

  private var defaultAvatar: some View {
    Image(systemName: "person.circle")
      .resizable()
      .aspectRatio(contentMode: .fit)
  }

  /// User name and email display

  private var userInfo: some View {
    VStack(alignment: .leading) {
      Text(user.profile?.name ?? "Unknown")
        .font(.headline)
      Text(user.profile?.email ?? "Unknown")
        .font(.subheadline)
    }
  }

  /// Sign out button

  private var signOutButton: some View {
    Button("Sign out", action: handleSignOut)
  }
}
