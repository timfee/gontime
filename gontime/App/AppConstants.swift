//
//  Constants.swift
//  gontime
//

import SwiftUI
import Foundation

enum AppConstants {
    enum MenuBar {
        static let defaultTitle = "Calendar"
        static let allClearTitle = "All clear"
        static let errorTitle = "⚠\u{fe0f} Calendar error"
        static let untitledEvent = "Untitled Event"
        
        enum TimeFormat {
            static let now = "Now"
            static let nextMeeting = "next meeting"
            
            static let withTitle = [
                "hours": "%dh until %@",
                "minutes": "%dm until %@",
                "now": "Now: %@"
            ]
            
            static let noTitle = [
                "hours": "%dh until \(nextMeeting)",
                "minutes": "%dm until \(nextMeeting)"
            ]
        }
    }
    
    enum Text {
        static let bracketsAndParens = "\\[.*?\\]|\\(.*?\\)"
        static let multipleSpaces = "\\s+"
    }
}

struct EventMockData: View {
    var body: some View {
        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.date(
            bySettingHour: calendar.component(.hour, from: now), minute: 0,
            second: 0, of: now)!
        
        VStack(spacing: 0) {
            // 1. One hour meeting with Google Meet (in progress)
            EventRow(
                event: GoogleEvent(
                    kind: "calendar#event",
                    etag: "123",
                    id: "preview-1",
                    status: "confirmed",
                    summary: "Team Standup",
                    start: EventDateTime(dateTime: currentHour, date: nil),
                    end: EventDateTime(
                        dateTime: currentHour.addingTimeInterval(3600),
                        date: nil),
                    attendees: [],
                    htmlLink: URL(string: "https://example.com")!,
                    conferenceData: ConferenceData(
                        conferenceId: "abc-123",
                        entryPoints: [
                            EntryPoint(
                                entryPointType: "video",
                                uri: "https://meet.google.com/abc-123",
                                label: "Join Meeting",
                                pin: nil,
                                regionCode: nil
                            )
                        ],
                        conferenceSolution: ConferenceSolution(
                            key: Key(type: "hangoutsMeet"),
                            name: "Google Meet",
                            iconUri:
                                "https://fonts.gstatic.com/s/i/productlogos/meet_2020q4/v1/web-96dp/logo_meet_2020q4_color_2x_web_96dp.png"
                        )
                    )
                )
            )
            
            // 2. 30 minute meeting with Google Meet
            EventRow(
                event: GoogleEvent(
                    kind: "calendar#event",
                    etag: "456",
                    id: "preview-2",
                    status: "confirmed",
                    summary: "Product Review",
                    start: EventDateTime(
                        dateTime: currentHour.addingTimeInterval(3600),
                        date: nil),
                    end: EventDateTime(
                        dateTime: currentHour.addingTimeInterval(3600 + 1800),
                        date: nil),
                    attendees: [],
                    htmlLink: URL(string: "https://example.com")!,
                    conferenceData: ConferenceData(
                        conferenceId: "def-456",
                        entryPoints: [
                            EntryPoint(
                                entryPointType: "video",
                                uri: "https://meet.google.com/def-456",
                                label: "Join Meeting",
                                pin: nil,
                                regionCode: nil
                            )
                        ],
                        conferenceSolution: ConferenceSolution(
                            key: Key(type: "hangoutsMeet"),
                            name: "Google Meet",
                            iconUri:
                                "https://fonts.gstatic.com/s/i/productlogos/meet_2020q4/v1/web-96dp/logo_meet_2020q4_color_2x_web_96dp.png"
                        )
                    )
                )
            )
            
            // 3. 45 minute meeting with Google Meet
            EventRow(
                event: GoogleEvent(
                    kind: "calendar#event",
                    etag: "789",
                    id: "preview-3",
                    status: "confirmed",
                    summary: "Design Sync",
                    start: EventDateTime(
                        dateTime: currentHour.addingTimeInterval(5400),
                        date: nil),
                    end: EventDateTime(
                        dateTime: currentHour.addingTimeInterval(5400 + 2700),
                        date: nil),
                    attendees: [],
                    htmlLink: URL(string: "https://example.com")!,
                    conferenceData: ConferenceData(
                        conferenceId: "ghi-789",
                        entryPoints: [
                            EntryPoint(
                                entryPointType: "video",
                                uri: "https://meet.google.com/ghi-789",
                                label: "Join Meeting",
                                pin: nil,
                                regionCode: nil
                            )
                        ],
                        conferenceSolution: ConferenceSolution(
                            key: Key(type: "hangoutsMeet"),
                            name: "Google Meet",
                            iconUri:
                                "https://fonts.gstatic.com/s/i/productlogos/meet_2020q4/v1/web-96dp/logo_meet_2020q4_color_2x_web_96dp.png"
                        )
                    )
                )
            )
            
            // 4. 15 minute meeting without conference
            EventRow(
                event: GoogleEvent(
                    kind: "calendar#event",
                    etag: "abc",
                    id: "preview-4",
                    status: "confirmed",
                    summary: "Quick Catch-up",
                    start: EventDateTime(
                        dateTime: currentHour.addingTimeInterval(8100),
                        date: nil),
                    end: EventDateTime(
                        dateTime: currentHour.addingTimeInterval(8100 + 900),
                        date: nil),
                    attendees: [],
                    htmlLink: URL(string: "https://example.com")!,
                    conferenceData: nil
                )
            )
            
            // 5. Another 15 minute meeting without conference
            EventRow(
                event: GoogleEvent(
                    kind: "calendar#event",
                    etag: "xyz",
                    id: "preview-5",
                    status: "confirmed",
                    summary: "Status Update",
                    start: EventDateTime(
                        dateTime: currentHour.addingTimeInterval(9000),
                        date: nil),
                    end: EventDateTime(
                        dateTime: currentHour.addingTimeInterval(9000 + 900),
                        date: nil),
                    attendees: [],
                    htmlLink: URL(string: "https://example.com")!,
                    conferenceData: nil
                )
            )
        }
    }
}
