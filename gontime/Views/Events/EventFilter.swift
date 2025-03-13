//
//  EventFilter.swift
//  gontime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@google.com
//

import Defaults
import Foundation

// MARK: - Event Filter Protocol

/// Defines interface for filtering calendar events
protocol EventFilterProtocol {

  func filter(_ events: [GoogleEvent]) -> [GoogleEvent]
}

// MARK: - Default Event Filter

/// Implements standard event filtering based on user preferences

struct DefaultEventFilter: EventFilterProtocol {

  func filter(_ events: [GoogleEvent]) -> [GoogleEvent] {
    events.filter { event in

      // Skip full-day events if configured
      guard !(Defaults[.ignoreFullDayEvents] && event.start?.dateTime == nil) else {
        return false
      }

      // Skip events without attendees if configured
      guard !(Defaults[.ignoreEventsWithoutAttendees] && event.attendees?.isEmpty ?? true) else {
        return false
      }

      return true
    }
  }
}
