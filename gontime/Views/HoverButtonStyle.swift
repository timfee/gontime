//
//  HoverButtonStyle.swift
//  gOnTime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@ (Tim Feeley)
//

import SwiftUI

/// A button style that shows a hover effect and responds to focus state
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
  static var hover: HoverButtonStyle { HoverButtonStyle() }

  static func hover(
    height: CGFloat = HoverButtonStyle.Constants.defaultHeight,
    cornerRadius: CGFloat = HoverButtonStyle.Constants.defaultCornerRadius
  ) -> HoverButtonStyle {
    HoverButtonStyle(height: height, cornerRadius: cornerRadius)
  }
}
