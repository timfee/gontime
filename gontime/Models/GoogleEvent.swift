//
//  GoogleEvent.swift
//  gontime
//
//  Created by Tim Feeley on 2/20/25.
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
    
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    var startTime: Date? { start?.dateTime ?? start?.date }
    var endTime: Date? { end?.dateTime ?? end?.date }
    
    var formattedStartTime: String? {
        guard let start = startTime else { return nil }
        return Self.timeFormatter.string(from: start)
    }
    
    var isInProgress: Bool {
        guard let start = startTime, let end = endTime else { return false }
        let now = Date()
        return now >= start && now <= end
    }
    
    var isUpcoming: Bool {
        guard let start = startTime else { return false }
        let now = Date()
        return start > now
    }
    
    var timeUntilStart: (minutes: Int, hours: Int)? {
        guard let start = startTime else { return nil }
        let now = Date()
        
        guard start > now else { return nil }
        
        let timeInterval = start.timeIntervalSince(now)
        let totalMinutes = Int(timeInterval / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        return (minutes, hours)
    }
    
    var timeUntilEnd: (minutes: Int, hours: Int)? {
        guard isInProgress,
              let end = endTime else { return nil }
        
        let interval = end.timeIntervalSince(Date())
        let totalMinutes = Int(interval / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        return (minutes, hours)
    }
}

struct EventDateTime: Codable {
    let dateTime: Date?
    let date: Date?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let dateTimeString = try? container.decode(String.self, forKey: .dateTime) {
            dateTime = Self.iso8601Formatter.date(from: dateTimeString)
        } else {
            dateTime = nil
        }
        
        if let dateString = try? container.decode(String.self, forKey: .date) {
            date = Self.dateFormatter.date(from: dateString)
        } else {
            date = nil
        }
    }
    
    init(dateTime: Date?, date: Date?) {
        self.dateTime = dateTime
        self.date = date
    }
    
    private static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
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
