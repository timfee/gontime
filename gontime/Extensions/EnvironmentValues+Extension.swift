//
//  EnvironmentValues+Extension.swift
//  gontime
//
//  Created by Tim Feeley on 2/22/25.
//

import SwiftUI

/// Extends EnvironmentValues to support time column width configuration
extension EnvironmentValues {
    /// The width of the time column in views
    var timeColumnWidth: CGFloat {
        get { self[TimeColumnWidthKey.self] }
        set { self[TimeColumnWidthKey.self] = newValue }
    }
}

/// Environment key for storing the time column width
private struct TimeColumnWidthKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0
}
