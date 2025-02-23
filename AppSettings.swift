//
//  AppSettings.swift
//  gontime
//

import Foundation
import SwiftUI

@MainActor
class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    // MARK: - Event Display Settings
    @AppStorage("hideAllDayEvents") var hideAllDayEvents = false
    @AppStorage("showEventTitlesInMenuBar") var showEventTitlesInMenuBar = true
    @AppStorage("maxEventTitleLength") var maxEventTitleLength = 30
    @AppStorage("cleanEventTitles") var cleanEventTitles = true
    
    private init() {}
}

// MARK: - Title Processing
extension AppSettings {
    func processEventTitle(_ title: String) -> String {
        guard showEventTitlesInMenuBar else { return "Next Event" }
        
        var processedTitle = title
        
        if cleanEventTitles {
            // Remove content within parentheses and brackets
            processedTitle = processedTitle.replacingOccurrences(
                of: "\\[.*?\\]|\\(.*?\\)",
                with: "",
                options: .regularExpression
            )
            .trimmingCharacters(in: .whitespaces)
        }
        
        if processedTitle.count > maxEventTitleLength {
            let index = processedTitle.index(processedTitle.startIndex, offsetBy: maxEventTitleLength)
            processedTitle = String(processedTitle[..<index]) + "…"
        }
        
        return processedTitle
    }
}

