//
//  Extensions/EnvironmentValues+Extension.swift
//  gOnTime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@ (Tim Feeley)
//

import SwiftUI

extension EnvironmentValues {
  var timeColumnWidth: CGFloat {
    get { self[TimeColumnWidthKey.self] }
    set { self[TimeColumnWidthKey.self] = newValue }
  }
}
private struct TimeColumnWidthKey: EnvironmentKey {
  static let defaultValue: CGFloat = 0
}
