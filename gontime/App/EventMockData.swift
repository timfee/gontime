//
//  EventMockData.swift
//  gOnTime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@ (Tim Feeley)
//

import SwiftUI

/// Provides mock data for events to be used in previews or testing.
struct EventMockData: View {
  // MARK: - Constants

  private enum Constants {
    static let googleMeetIcon =
      "https://fonts.gstatic.com/s/i/productlogos/meet_2020q4/v1/web-96dp/logo_meet_2020q4_color_2x_web_96dp.png"
  }

  // MARK: - Body

  var body: some View {
    let now = Date()
    let calendar = Calendar.current
    let currentHour = calendar.date(
      bySettingHour: calendar.component(.hour, from: now),
      minute: 0,
      second: 0,
      of: now
    )!

    VStack(spacing: 0) {
      Group {
        createMeetingEvent(
          id: "preview-1",
          title: "Team Standup",
          startTime: currentHour,
          duration: 3600,
          meetingId: "abc-123"
        )
        createMeetingEvent(
          id: "preview-2",
          title: "Product Review",
          startTime: currentHour.addingTimeInterval(3600),
          duration: 1800,
          meetingId: "def-456"
        )
        createMeetingEvent(
          id: "preview-3",
          title: "Design Sync",
          startTime: currentHour.addingTimeInterval(5400),
          duration: 2700,
          meetingId: "ghi-789"
        )
        createBasicEvent(
          id: "preview-4",
          title: "Quick Catch-up",
          startTime: currentHour.addingTimeInterval(8100),
          duration: 900
        )
        createBasicEvent(
          id: "preview-5",
          title: "Status Update",
          startTime: currentHour.addingTimeInterval(9000),
          duration: 900
        )
      }
    }
  }

  // MARK: - Private Methods

  /// Creates a mock meeting event with conference data.
  private func createMeetingEvent(
    id: String,
    title: String,
    startTime: Date,
    duration: TimeInterval,
    meetingId: String
  ) -> some View {
    EventRow(
      event: GoogleEvent(
        kind: "calendar#event",
        etag: id,
        id: id,
        status: "confirmed",
        summary: title,
        start: EventDateTime(dateTime: startTime, date: nil),
        end: EventDateTime(
          dateTime: startTime.addingTimeInterval(duration),
          date: nil
        ),
        attendees: [],
        htmlLink: URL(string: "https://example.com")!,
        conferenceData: ConferenceData(
          conferenceId: meetingId,
          entryPoints: [
            EntryPoint(
              entryPointType: "video",
              uri: "https://meet.google.com/\(meetingId)",
              label: "Join Meeting",
              pin: nil,
              regionCode: nil
            )
          ],
          conferenceSolution: ConferenceSolution(
            key: Key(type: "hangoutsMeet"),
            name: "Google Meet",
            iconUri: Constants.googleMeetIcon
          )
        )
      )
    )
  }

  /// Creates a mock basic event without conference data.
  private func createBasicEvent(
    id: String,
    title: String,
    startTime: Date,
    duration: TimeInterval
  ) -> some View {
    EventRow(
      event: GoogleEvent(
        kind: "calendar#event",
        etag: id,
        id: id,
        status: "confirmed",
        summary: title,
        start: EventDateTime(dateTime: startTime, date: nil),
        end: EventDateTime(
          dateTime: startTime.addingTimeInterval(duration),
          date: nil
        ),
        attendees: [],
        htmlLink: URL(string: "https://example.com")!,
        conferenceData: nil
      )
    )
  }
}
