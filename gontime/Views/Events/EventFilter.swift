//
//  EventFilter.swift
//  gontime
//

import Foundation
import Defaults

// MARK: - Protocols
protocol EventFilterProtocol {
    func filter(_ events: [GoogleEvent]) -> [GoogleEvent]
}

// MARK: - Default Implementation
struct DefaultEventFilter: EventFilterProtocol {
    /// Filters events based on user preferences:
    /// - Removes full-day events if ignoreFullDayEvents is enabled
    /// - Removes events without attendees if ignoreEventsWithoutAttendees is enabled
    /// - Parameters:
    ///   - events: Array of GoogleEvent objects to filter
    /// - Returns: Filtered array of GoogleEvent objects
    func filter(_ events: [GoogleEvent]) -> [GoogleEvent] {
        events.filter { event in
            guard !(Defaults[.ignoreFullDayEvents] && event.start?.dateTime == nil) else {
                return false
            }
            
            guard !(Defaults[.ignoreEventsWithoutAttendees] && event.attendees?.isEmpty ?? true) else {
                return false
            }
            
            return true
        }
    }
}
