//
//  Extensions/HorizontalAlignment+Extension.swift
//  gOnTime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@ (Tim Feeley)
//

import SwiftUI

extension HorizontalAlignment {
  private enum TimeAlignment: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
      context[.leading]
    }
  }
  static let timeAlignmentGuide = HorizontalAlignment(TimeAlignment.self)
}
