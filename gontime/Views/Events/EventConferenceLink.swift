//
//  EventConferenceLink.swift
//  gOnTime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@google.com
//

import SwiftUI

// MARK: - Conference Link View

/// Displays a clickable conference link with provider icon or name
struct EventConferenceLink: View {

  @Environment(\.openURL) private var openURL

  // MARK: - Constants

  private enum Constants {
    static let iconSize: CGFloat = 16
    static let trailingPadding: CGFloat = 4
  }

  // MARK: - Properties

  let uri: String
  let solution: ConferenceSolution
  let isInProgress: Bool

  // MARK: - View Body

  var body: some View {
    Button {
      openURL(URL(string: uri)!)
    } label: {
      conferenceIcon
    }
    .help("Join \(solution.name)")
    .focusable()
    .buttonBorderShape(.roundedRectangle)
    .buttonStyle(for: isInProgress)
    .opacity(isInProgress ? 1.0 : 0.6)
    .padding(.trailing, Constants.trailingPadding)
  }

  // MARK: - Private Views

  /// Displays either a provider icon or fallback text label
  @ViewBuilder
  private var conferenceIcon: some View {
    if let iconUrl = solution.iconUri,
      let url = URL(string: iconUrl)
    {
      AsyncImage(url: url) { image in
        image.resizable()
          .frame(
            width: Constants.iconSize,
            height: Constants.iconSize
          )
      } placeholder: {
        Image(systemName: "video.fill")
          .frame(
            width: Constants.iconSize,
            height: Constants.iconSize
          )
      }
    } else {
      Text(solution.name)
        .font(.footnote)
        .foregroundColor(.blue)
    }
  }
}
