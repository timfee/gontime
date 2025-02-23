//
//  MenuBarDecorator.swift
//  gontime
//

import Combine
import Defaults
import Foundation

protocol MenuBarDecoratorProtocol {
    func decorateTitle(error: String?, events: [GoogleEvent]) -> String
}

final class MenuBarDecorator: MenuBarDecoratorProtocol {
    private var cancellables = Set<AnyCancellable>()
    
    func decorateTitle(error: String?, events: [GoogleEvent]) -> String {
        if let error = error {
            return Constants.MenuBar.errorTitle
        }
        
        guard let event = events.first else {
            return Constants.MenuBar.allClearTitle
        }
        
        return formatEventTitle(for: event)
    }
    
    private func formatEventTitle(for event: GoogleEvent) -> String {
        let showTitle = Defaults[.showEventTitleInMenuBar]
        
        // First handle the in-progress case since it's special
        if event.isInProgress {
            return showTitle
                ? String(format: Constants.MenuBar.TimeFormat.withTitle["now"]!,
                         formatTitle(event))
                : Constants.MenuBar.TimeFormat.now
        }
        
        // Then handle upcoming events
        if let timeUntil = event.timeUntilStart {
            let timeKey = timeUntil.hours > 0 ? "hours" : "minutes"
            let timeValue = timeUntil.hours > 0 ? timeUntil.hours : timeUntil.minutes
            
            if showTitle {
                return String(
                    format: Constants.MenuBar.TimeFormat.withTitle[timeKey]!,
                    timeValue,
                    formatTitle(event)
                )
            } else {
                return String(
                    format: Constants.MenuBar.TimeFormat.noTitle[timeKey]!,
                    timeValue
                )
            }
        }
        
        return Constants.MenuBar.allClearTitle
    }
    
    private func formatTitle(_ event: GoogleEvent) -> String {
        formatTitle(
            event.summary ?? Constants.MenuBar.untitledEvent,
            truncateLength: Defaults[.truncatedEventTitleLength],
            simplify: Defaults[.simplifyEventTitles]
        )
    }
    
    private func formatTitle(_ title: String, truncateLength: Int, simplify: Bool) -> String {
        var formatted = title
        
        if simplify {
            formatted = formatted.replacingOccurrences(
                of: Constants.Text.bracketsAndParens,
                with: "",
                options: .regularExpression
            )
            formatted = formatted.replacingOccurrences(
                of: Constants.Text.multipleSpaces,
                with: " ",
                options: .regularExpression
            )
            formatted = formatted.trimmingCharacters(in: .whitespaces)
        }
        
        if formatted.count > truncateLength {
            let index = formatted.index(formatted.startIndex, offsetBy: truncateLength - 1)
            formatted = String(formatted[..<index]) + "…"
        }
        
        return formatted
    }
}

// End of file
