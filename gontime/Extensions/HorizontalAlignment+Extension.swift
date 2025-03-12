//
//  HorizontalAlignment+Extension.swift
//  gOnTime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@google.com
//

import SwiftUI

// MARK: - HorizontalAlignment Extension

/// Extends HorizontalAlignment to provide custom alignment for time-based views
extension HorizontalAlignment {

  /// Custom alignment ID for time-based content
  private enum TimeAlignment: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
      context[.leading]
    }
  }

  /// Alignment guide for consistent time column layout
  static let timeAlignmentGuide = HorizontalAlignment(TimeAlignment.self)
}
