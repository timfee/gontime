//
//  MenuBarDecorator.swift
//  gOnTime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@ (Tim Feeley)
//

import Combine
import Defaults
import Foundation

// MARK: - Menu Bar Title Generator Protocol
/// Defines interface for generating menu bar titles
protocol MenuBarTitleGenerator {
    func generateTitle(error: String?, events: [GoogleEvent]) -> String
}

// MARK: - Menu Bar Decorator
/// Formats and decorates menu bar titles based on event status and user preferences
final class MenuBarDecorator: MenuBarTitleGenerator {
    // MARK: - Constants
    
    private enum Constants {
        static let error = "⚠\u{fef} Calendar error"
        static let allClear = "All clear"
        static let untitled = "Untitled Event"
        static let nextMeeting = "next meeting"
        static let now = "Now"
    }
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Methods
    
    func generateTitle(error: String?, events: [GoogleEvent]) -> String {
        if error != nil { return Constants.error }
        guard let event = events.first else { return Constants.allClear }
        return generateEventStatus(for: event)
    }
    
    // MARK: - Private Helpers
    
    /// Generates status text for the menu bar based on event timing
    private func generateEventStatus(for event: GoogleEvent) -> String {
        let title =
        Defaults[.showEventTitleInMenuBar]
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
    
    /// Applies title simplification and truncation based on user preferences
    private func simplifyTitle(_ title: String) -> String {
        var result = title
        
        if Defaults[.simplifyEventTitles] {
            result =
            result
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
