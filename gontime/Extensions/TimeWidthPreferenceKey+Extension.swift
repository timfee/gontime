//
//  TimeWidthPreferenceKey.swift
//  gontime
//
//  Created by Tim Feeley on 2/22/25.
//

import SwiftUI

/// PreferenceKey for managing time width measurements in views
struct TimeWidthPreferenceKey: PreferenceKey {
    /// Default width value
    static var defaultValue: CGFloat = 0
    
    /// Combines multiple width values by taking the maximum
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
