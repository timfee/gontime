//
//  TimeAlignment.swift
//  gontime
//
//  Created by Tim Feeley on 2/22/25.
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

