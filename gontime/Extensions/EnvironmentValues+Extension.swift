//
//  EnvironmentValues+Extension.swift
//  gontime
//
//  Created by Tim Feeley on 2/22/25.
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
