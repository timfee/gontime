//
//  TimeWidthPreferenceKey+Extension.swift
//  gontime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@google.com
//

import SwiftUI

// MARK: - Time Width Preference Key

/// Tracks the maximum width needed for time-based content layout

struct TimeWidthPreferenceKey: PreferenceKey {
  static var defaultValue: CGFloat = 0

  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = max(value, nextValue())
  }
}
