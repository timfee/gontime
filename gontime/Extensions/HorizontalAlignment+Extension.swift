//
//  TimeAlignment.swift
//  gontime
//
//  Created by Tim Feeley on 2/22/25.
//

import SwiftUI

/// Extends HorizontalAlignment to provide custom alignment for time-based views
extension HorizontalAlignment {
    // MARK: - Custom Alignment
    
    /// Custom alignment for time-based elements
    private enum TimeAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[.leading]
        }
    }
    
    /// Alignment guide for time-based elements in views
    static let timeAlignmentGuide = HorizontalAlignment(TimeAlignment.self)
}
