//
//  GoogleEvent.swift
//  gontime
//
//  Created by Tim Feeley on 2/20/25.
//

import Foundation

// Your imports remain the same

// MARK: - Response Container
/// Represents the response from Google Calendar API containing events
struct GoogleEventsResponse: Codable {
    let items: [GoogleEvent]
}

// MARK: - Main Event Model
/// Represents a Google Calendar event with its associated data
struct GoogleEvent: Codable, Identifiable {
    // MARK: Properties
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
    
    // MARK: Computed Properties
    /// The event's start time, preferring dateTime over date
    var startTime: Date? { start?.dateTime ?? start?.date }
    
    /// The event's end time, preferring dateTime over date
    var endTime: Date? { end?.dateTime ?? end?.date }
    
    /// Formatted start time string
    var formattedStartTime: String? {
        guard let startTime = startTime else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: startTime)
    }
    
    /// Whether the event is currently in progress
    var isInProgress: Bool {
        guard let start = startTime,
              let end = endTime else { return false }
        let now = Date()
        // Use floor comparison for start time to handle edge cases
        return now.timeIntervalSince(start) >= 0 && now <= end
    }
    
    /// Time until the event starts, in (minutes, hours)
    var timeUntilStart: (minutes: Int, hours: Int)? {
        guard let start = startTime else { return nil }
        let now = Date()
        // Return nil if we're at or past the start time
        guard start.timeIntervalSince(now) > 0 else { return nil }
        
        let timeInterval = start.timeIntervalSince(now)
        let totalMinutes = Int(timeInterval / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return (minutes, hours)
    }
    
    /// Time until the event ends, in (minutes, hours)
    var timeUntilEnd: (minutes: Int, hours: Int)? {
        guard isInProgress,
              let end = endTime else { return nil }
        let now = Date()
        
        let timeInterval = end.timeIntervalSince(now)
        let totalMinutes = Int(timeInterval / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return (minutes, hours)
    }
}

// MARK: - Event Date Time
/// Represents the date/time for an event's start or end
struct EventDateTime: Codable {
    // MARK: Properties
    let dateTime: Date?
    let date: Date?
    
    // MARK: Initialization
    /// Creates an EventDateTime with optional dateTime and date values
    /// - Parameters:
    ///   - dateTime: The date and time of the event
    ///   - date: The date of an all-day event
    init(dateTime: Date?, date: Date?) {
        self.dateTime = dateTime
        self.date = date
    }
    
    init(from decoder: Decoder) throws {
        // Initialize formatters only when needed for decoding
        let iso8601Formatter = ISO8601DateFormatter()
        iso8601Formatter.formatOptions = [.withInternetDateTime]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = .gmt
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        dateTime = try container
            .decodeIfPresent(String.self, forKey: .dateTime)
            .flatMap(iso8601Formatter.date)
        
        date = try container
            .decodeIfPresent(String.self, forKey: .date)
            .flatMap(dateFormatter.date)
    }
}

// MARK: - Attendee
/// Represents an attendee of a calendar event
struct Attendee: Codable {
    let email: String
    let displayName: String?
    let responseStatus: String
    let optional: Bool?
    let organizer: Bool?
    let resource: Bool?
}

// MARK: - Conference Data
/// Represents conference/meeting details for an event
struct ConferenceData: Codable {
    let conferenceId: String
    let entryPoints: [EntryPoint]?
    let conferenceSolution: ConferenceSolution?
}

// MARK: - Conference Solution
/// Represents the solution used for conference (e.g., Google Meet, Zoom)
struct ConferenceSolution: Codable {
    let key: Key
    let name: String
    let iconUri: String?
}

/// Represents the type of conference solution
struct Key: Codable {
    let type: String
}

// MARK: - Entry Point
/// Represents how to join a conference (URL, phone number, etc.)
struct EntryPoint: Codable {
    let entryPointType: String
    let uri: String
    let label: String?
    let pin: String?
    let regionCode: String?
}
