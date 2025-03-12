//
//  MenuBarDecorator.swift
//  gontime
//

import Combine
import Defaults
import Foundation

/// Generates menu bar title text based on calendar event status and user preferences
protocol MenuBarTitleGenerator {
    func generateTitle(error: String?, events: [GoogleEvent]) -> String
}

/// Formats event information into menu bar title text
/// Handles error states, empty states, and formats event timing with optional title display
final class MenuBarDecorator: MenuBarTitleGenerator {
    // MARK: - Constants
    private enum Constants {
        static let error = "⚠\u{fef} Calendar error"
        static let allClear = "All clear"
        static let untitled = "Untitled Event"
        static let nextMeeting = "next meeting"
        static let now = "Now"
    }
    
    // MARK: - Public Interface
    
    /// Generates the menu bar title based on current state
    /// - Parameters:
    ///   - error: Optional error message indicating calendar access issues
    ///   - events: Array of upcoming calendar events
    /// - Returns: Formatted string for display in menu bar
    func generateTitle(error: String?, events: [GoogleEvent]) -> String {
        if error != nil { return Constants.error }
        guard let event = events.first else { return Constants.allClear }
        
        return generateEventStatus(for: event)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Private Methods
    
    /// Formats event status based on timing and user preferences
    private func generateEventStatus(for event: GoogleEvent) -> String {
        let title = Defaults[.showEventTitleInMenuBar]
        ? simplifyTitle(event.summary ?? Constants.untitled)
        : Constants.nextMeeting
        
        if event.isInProgress {
            return Defaults[.showEventTitleInMenuBar] ? "\(Constants.now): \(title)" : Constants.now
        }
        
        guard let timeUntil = event.timeUntilStart else { return Constants.allClear }
        return timeUntil.hours > 0
        ? "\(timeUntil.hours)h until \(title)"
        : "\(timeUntil.minutes)m until \(title)"
    }
    
    /// Simplifies and truncates event title based on user preferences
    private func simplifyTitle(_ title: String) -> String {
        var result = title
        
        if Defaults[.simplifyEventTitles] {
            result = result
                .replacingOccurrences(of: "\\[.*?\\]|\\(.*?\\)", with: "", options: .regularExpression)
                .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
                .trimmingCharacters(in: .whitespaces)
        }
        
        let maxLength = Defaults[.truncatedEventTitleLength]
        if result.count > maxLength {
            result = String(result.prefix(maxLength - 1)) + "…"
        }
        
        return result
    }
}
