//
//  EventRow.swift
//  gontime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@google.com
//

import SwiftUI

// MARK: - Event Row View

/// Displays a single calendar event with time, title, and interaction links
struct EventRow: View {
  private enum Constants {
    static let spacing: CGFloat = 12
  }
  let event: GoogleEvent
  @Environment(\.isFocused) var isFocused
  @Environment(\.timeColumnWidth) private var timeColumnWidth
  var body: some View {
    Button(action: { NSWorkspace.shared.open(event.htmlLink) }) {
      HStack(spacing: Constants.spacing) {
        timeColumn
        titleColumn
        Spacer()
        conferenceLink
        calendarLink
      }
    }
    .buttonStyle(.hover)
    .focusable()
  }

  // MARK: - Private Views

  /// Time column with dynamic width adjustment

  private var timeColumn: some View {
    HStack {
      Text(formattedTimeText)
        .font(.subheadline)
        .foregroundStyle(
          event.timeUntilEnd != nil
            ? .white : .primary
        )
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
        .background(
          Group {
            if event.timeUntilEnd != nil {
              Capsule()
                .fill(Color.accentColor)
            } else {
              Color.clear
            }
          }
        )
        .background(timeWidthReader)
    }
    .alignmentGuide(.timeAlignmentGuide) { $0[.trailing] }
    .frame(minWidth: timeColumnWidth, alignment: .trailing)
  }

  /// Event title with truncation

  private var titleColumn: some View {
    Text(event.summary ?? "Unnamed event")
      .font(.subheadline)
      .lineLimit(1)
      .truncationMode(.tail)
  }

  /// Conference link if available

  @ViewBuilder
  private var conferenceLink: some View {
    if let conference = event.conferenceData,
      let entryPoint = conference.entryPoints?.first(where: {
        $0.entryPointType == "video"
      }),
      let solution = conference.conferenceSolution
    {
      EventConferenceLink(
        uri: entryPoint.uri,
        solution: solution,
        isInProgress: event.isInProgress
      )
    }
  }

  /// Link to calendar event

  private var calendarLink: some View {
    Link(destination: event.htmlLink) {
      Image(systemName: "chevron.right.circle")
        .foregroundColor(.secondary)
    }
    .help("Open in Calendar")
    .buttonStyle(.plain)
    .focusable()
  }

  /// Measures time column width for alignment

  private var timeWidthReader: some View {
    GeometryReader { geometry in
      Color.clear.preference(
        key: TimeWidthPreferenceKey.self,
        value: geometry.size.width
      )
    }
  }

  // MARK: - Private Helpers

  /// Formats time text based on event status

  private var formattedTimeText: String {
    if let timeLeft = event.timeUntilEnd {

      // If time until end is 0, show "Ending"
      if timeLeft.hours == 0 && timeLeft.minutes == 0 {
        return "Ending"
      }
      return formatTimeLeft(
        hours: timeLeft.hours, minutes: timeLeft.minutes)
    }

    // If time until start is 0, show "Now"
    if let timeUntilStart = event.timeUntilStart,
      timeUntilStart.hours == 0 && timeUntilStart.minutes == 0
    {
      return "Now"
    }
    return event.formattedStartTime ?? ""
  }

  /// Formats remaining time in hours and minutes

  private func formatTimeLeft(hours: Int, minutes: Int) -> String {
    hours > 0
      ? "\(hours):\(String(format: "%02d", minutes)) left"
      : "\(minutes)m left"
  }

  // The rest of the file remains the same
}

// MARK: - Previews

#Preview {
  @Previewable @State var timeColumnWidth: CGFloat = 0
  return VStack(spacing: 0) {
    VStack(alignment: .timeAlignmentGuide, spacing: 0) {
      EventMockData().allowsHitTesting(false)
    }
    .onPreferenceChange(TimeWidthPreferenceKey.self) { width in
      timeColumnWidth = width
    }
    .environment(\.timeColumnWidth, timeColumnWidth)
  }
  .frame(width: 400)
  .padding()
}
