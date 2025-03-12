//
//  HoverButtonStyle.swift
//  gOnTime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@google.com
//

import SwiftUI

/// A button style that provides visual feedback for hover and focus states
struct HoverButtonStyle: ButtonStyle {

  // MARK: - Constants

  enum Constants {
    static let defaultHeight: CGFloat = 32
    static let defaultCornerRadius: CGFloat = 8
    static let horizontalPadding: CGFloat = 8
    static let hoverOpacity: CGFloat = 0.1
  }

  // MARK: - Properties

  @Environment(\.isFocused) private var isFocused
  @State private var isHovered: Bool = false

  private let height: CGFloat
  private let cornerRadius: CGFloat

  // MARK: - Initialization

  /// Creates a hover button style with custom dimensions
  /// - Parameters:
  ///   - height: Button height (defaults to 32)
  ///   - cornerRadius: Corner radius for the button background (defaults to 8)
  init(
    height: CGFloat = Constants.defaultHeight,
    cornerRadius: CGFloat = Constants.defaultCornerRadius
  ) {
    self.height = height
    self.cornerRadius = cornerRadius
  }

  // MARK: - ButtonStyle Implementation

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .frame(maxWidth: .infinity, alignment: .leading)
      .frame(height: height)
      .padding(.horizontal, Constants.horizontalPadding)
      .background(
        RoundedRectangle(cornerRadius: cornerRadius)
          .fill(backgroundColor)
      )
      .contentShape(.rect(cornerRadius: cornerRadius))
      .onHover { isHovered = $0 }
      .focusable()
      .focusEffectDisabled(true)
  }

  // MARK: - Private Helpers

  private var backgroundColor: Color {
    (isFocused || isHovered) ? .primary.opacity(Constants.hoverOpacity) : .clear
  }
}

extension ButtonStyle where Self == HoverButtonStyle {

  /// Default hover button style
  static var hover: HoverButtonStyle { HoverButtonStyle() }

  /// Creates a custom hover button style
  static func hover(
    height: CGFloat = HoverButtonStyle.Constants.defaultHeight,
    cornerRadius: CGFloat = HoverButtonStyle.Constants.defaultCornerRadius
  ) -> HoverButtonStyle {
    HoverButtonStyle(height: height, cornerRadius: cornerRadius)
  }
}
