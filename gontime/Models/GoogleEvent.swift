//
//  GoogleEvent.swift
//  gontime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@google.com
//

import Foundation

struct GoogleEventsResponse: Codable {
  let items: [GoogleEvent]
}

struct GoogleEvent: Codable, Identifiable {
  let kind: String
  let etag: String
  let id: String
  let status: String
  let summary: String?
  let start: EventDateTime?
  let end: EventDateTime?
  let attendees: [Attendee]?
  let htmlLink: URL
  let conferenceData: ConferenceData?
  var startTime: Date? { start?.dateTime ?? start?.date }
  var endTime: Date? { end?.dateTime ?? end?.date }

  var formattedStartTime: String? {
    guard let startTime = startTime else { return nil }
    let formatter = DateFormatter()
    formatter.dateFormat = "h:mm a"
    return formatter.string(from: startTime)
  }

  var isInProgress: Bool {
    guard let start = startTime,
      let end = endTime
    else { return false }
    let now = Date()
    return now.timeIntervalSince(start) >= 0 && now <= end
  }

  var timeUntilStart: (minutes: Int, hours: Int)? {
    guard let start = startTime else { return nil }
    let now = Date()
    let timeInterval = start.timeIntervalSince(now)

    // Convert to total minutes, rounding up for partial minutes
    let totalMinutes = Int(ceil(timeInterval / 60))
    let hours = totalMinutes / 60
    let minutes = totalMinutes % 60
    return (minutes, hours)
  }

  var timeUntilEnd: (minutes: Int, hours: Int)? {
    guard isInProgress,
      let end = endTime
    else { return nil }
    let now = Date()
    let timeInterval = end.timeIntervalSince(now)

    // Convert to total minutes, rounding up for partial minutes
    let totalMinutes = Int(ceil(timeInterval / 60))
    let hours = totalMinutes / 60
    let minutes = totalMinutes % 60
    return (minutes, hours)
  }
}

struct EventDateTime: Codable {
  let dateTime: Date?
  let date: Date?

  init(dateTime: Date?, date: Date?) {
    self.dateTime = dateTime
    self.date = date
  }

  init(from decoder: Decoder) throws {
    let iso8601Formatter = ISO8601DateFormatter()
    iso8601Formatter.formatOptions = [.withInternetDateTime]
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    dateFormatter.timeZone = .gmt
    let container = try decoder.container(keyedBy: CodingKeys.self)
    dateTime =
      try container
      .decodeIfPresent(String.self, forKey: .dateTime)
      .flatMap(iso8601Formatter.date)
    date =
      try container
      .decodeIfPresent(String.self, forKey: .date)
      .flatMap(dateFormatter.date)
  }
}

struct Attendee: Codable {
  let email: String
  let displayName: String?
  let responseStatus: String
  let optional: Bool?
  let organizer: Bool?
  let resource: Bool?
}

struct ConferenceData: Codable {
  let conferenceId: String
  let entryPoints: [EntryPoint]?
  let conferenceSolution: ConferenceSolution?
}

struct ConferenceSolution: Codable {
  let key: Key
  let name: String
  let iconUri: String?
}

struct Key: Codable {
  let type: String
}

struct EntryPoint: Codable {
  let entryPointType: String
  let uri: String
  let label: String?
  let pin: String?
  let regionCode: String?
}
