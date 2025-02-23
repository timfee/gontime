//
//  TimeWidthPreferenceKey.swift
//  gontime
//
//  Created by Tim Feeley on 2/22/25.
//

import SwiftUI

struct TimeWidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
