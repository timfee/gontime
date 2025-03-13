//
//  Settings+Extension.swift
//  gontime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@google.com
//

import Defaults

// MARK: - Default Settings Keys

extension Defaults.Keys {
  // MARK: Menu Bar Display Settings

  /// Controls visibility of event titles in the menu bar

  static let showEventTitleInMenuBar = Key<Bool>(
    "showEventTitleInMenuBar",
    default: true
  )

  /// Maximum length for truncated event titles

  static let truncatedEventTitleLength = Key<Int>(
    "truncatedEventTitleLength",
    default: 30
  )

  // MARK: Event Filtering Settings

  /// Enables simplified event title display

  static let simplifyEventTitles = Key<Bool>(
    "simplifyEventTitles",
    default: true
  )

  /// Controls whether full-day events are shown

  static let ignoreFullDayEvents = Key<Bool>(
    "ignoreFullDayEvents",
    default: true
  )

  /// Controls visibility of events without attendees

  static let ignoreEventsWithoutAttendees = Key<Bool>(
    "ignoreEventsWithoutAttendees",
    default: true
  )

  // MARK: Notification Settings

  /// Time in minutes before meeting for notification (optional)

  static let meetingNotificationTime = Key<Int?>(
    "meetingNotificationTime",
    default: 5
  )
}
