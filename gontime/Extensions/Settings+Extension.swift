//
//  Extensions/Settings+Extension.swift
//  gOnTime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@ (Tim Feeley)
//

import Defaults

extension Defaults.Keys {
  static let showEventTitleInMenuBar = Key<Bool>(
    "showEventTitleInMenuBar",
    default: true
  )
  static let truncatedEventTitleLength = Key<Int>(
    "truncatedEventTitleLength",
    default: 30
  )
  static let simplifyEventTitles = Key<Bool>(
    "simplifyEventTitles",
    default: true
  )
  static let ignoreFullDayEvents = Key<Bool>(
    "ignoreFullDayEvents",
    default: true
  )
  static let ignoreEventsWithoutAttendees = Key<Bool>(
    "ignoreEventsWithoutAttendees",
    default: true
  )
  static let meetingNotificationTime = Key<Int?>(
    "meetingNotificationTime",
    default: 5
  )
}
