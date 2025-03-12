//
//  EnvironmentValues+Extension.swift
//  gOnTime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@ (Tim Feeley)
//

import SwiftUI

// MARK: - Environment Values Extension
extension EnvironmentValues {
    /// Provides access to the time column width across the view hierarchy
    var timeColumnWidth: CGFloat {
        get { self[TimeColumnWidthKey.self] }
        set { self[TimeColumnWidthKey.self] = newValue }
    }
}

// MARK: - Private Environment Key
private struct TimeColumnWidthKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0
}
