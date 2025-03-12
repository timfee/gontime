//
//  Settings+Extension.swift
//  gontime
//
//  Created by Tim Feeley on 2/21/25.
//

import Defaults

/// Extends Defaults.Keys with application-specific settings
extension Defaults.Keys {
    // MARK: - Menu Bar Display Settings
    
    /// Whether to show the event title in the menu bar
    static let showEventTitleInMenuBar = Key<Bool>(
        "showEventTitleInMenuBar",
        default: true
    )
    
    /// Maximum length for truncated event titles
    static let truncatedEventTitleLength = Key<Int>(
        "truncatedEventTitleLength",
        default: 30
    )
    
    /// Whether to simplify event titles
    static let simplifyEventTitles = Key<Bool>(
        "simplifyEventTitles",
        default: true
    )
    
    // MARK: - Event Filtering Settings
    
    /// Whether to ignore full-day events
    static let ignoreFullDayEvents = Key<Bool>(
        "ignoreFullDayEvents",
        default: true
    )
    
    /// Whether to ignore events without attendees
    static let ignoreEventsWithoutAttendees = Key<Bool>(
        "ignoreEventsWithoutAttendees",
        default: true
    )
    
    // MARK: - Notification Settings
    
    /// Minutes before meeting to show notification (optional)
    static let meetingNotificationTime = Key<Int?>(
        "meetingNotificationTime",
        default: 5
    )
}
