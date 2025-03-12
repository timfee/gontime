//
//  SignedInUserView.swift
//  gOnTime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@ (Tim Feeley)
//

import GoogleSignIn
import SwiftUI

struct SignedInUserView: View {
  let user: GIDGoogleUser
  let handleSignOut: () -> Void
  var body: some View {
    HStack {
      userAvatar
      userInfo
      Spacer()
      signOutButton
    }
  }
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
  private var defaultAvatar: some View {
    Image(systemName: "person.circle")
      .resizable()
      .aspectRatio(contentMode: .fit)
  }
  private var userInfo: some View {
    VStack(alignment: .leading) {
      Text(user.profile?.name ?? "Unknown")
        .font(.headline)
      Text(user.profile?.email ?? "Unknown")
        .font(.subheadline)
    }
  }
  private var signOutButton: some View {
    Button("Sign out", action: handleSignOut)
  }
}
