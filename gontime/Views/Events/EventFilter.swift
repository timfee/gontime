//
//  Views/Events/EventFilter.swift
//  gOnTime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@ (Tim Feeley)
//

import Defaults
import Foundation

protocol EventFilterProtocol {
  func filter(_ events: [GoogleEvent]) -> [GoogleEvent]
}
struct DefaultEventFilter: EventFilterProtocol {
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
