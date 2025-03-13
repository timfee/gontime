//
//  UpdateView.swift
//  gontime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@google.com
//

import SwiftUI

/// A view that displays update information and provides update actions

@MainActor

struct UpdateView: View {
  let updateInfo: UpdateInfo
  @Environment(\.dismiss) private var dismiss
  @Environment(\.openURL) private var openURL

  // MARK: - View Components

  @ViewBuilder
  private var updateMessage: some View {
    if let attributedMessage = createAttributedMessage() {
      Text(AttributedString(attributedMessage))
        .fixedSize(horizontal: false, vertical: true)
    } else {
      Text(updateInfo.message)
        .fixedSize(horizontal: false, vertical: true)
    }
  }

  @ViewBuilder
  private var actionButtons: some View {
    HStack {
      Spacer()
      if !updateInfo.force {
        Button("Later") {
          dismiss()
        }
      }
      Button("Update Now", action: handleUpdate)
        .keyboardShortcut(.defaultAction)
    }
  }

  // MARK: - Body

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Update Available")
        .font(.title2)
        .bold()

      updateMessage
      Spacer()
      actionButtons
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(nsColor: .windowBackgroundColor))
  }

  // MARK: - Helper Methods

  private func createAttributedMessage() -> NSAttributedString? {
    guard let data = updateInfo.message.data(using: .utf8) else { return nil }

    return try? NSAttributedString(
      data: data,
      options: [.documentType: NSAttributedString.DocumentType.html],
      documentAttributes: nil
    )
  }

  private func handleUpdate() {
    guard let url = URL(string: updateInfo.url) else { return }

    openURL(url)
    if updateInfo.force {
      NSApplication.shared.terminate(nil)
    }
    dismiss()
  }
}
