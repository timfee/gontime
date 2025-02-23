//
//  AppSettings.swift
//  gontime
//
//  Created by Tim Feeley
//

import SwiftUI

@MainActor
final class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    @AppStorage("hideAllDayEvents") var hideAllDayEvents = false
    @AppStorage("showEventTitles") var showEventTitles = true
    @AppStorage("maxTitleLength") var maxTitleLength = 30
    @AppStorage("cleanEventTitles") var cleanEventTitles = true
    
    private init() {}
    
    func cleanTitle(_ title: String) -> String {
        guard cleanEventTitles else { return title }
        
        // Remove content within parentheses and brackets
        var cleaned = title.replacingOccurrences(of: "\([^)]*\)", with: "", options: .regularExpression)
        cleaned = cleaned.replacingOccurrences(of: "\[[^\]]*\]", with: "", options: .regularExpression)
        
        // Trim whitespace and return
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func truncateTitle(_ title: String) -> String {
        guard showEventTitles else { return "Next Event" }
        let cleaned = cleanEventTitles ? cleanTitle(title) : title
        
        if cleaned.count > maxTitleLength {
            let index = cleaned.index(cleaned.startIndex, offsetBy: maxTitleLength)
            return String(cleaned[..<index]) + "..."
        }
        return cleaned
    }
}

