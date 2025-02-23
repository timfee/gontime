//
//  EventRow.swift
//  gontime
//
//  Created by Tim Feeley on 2/20/25.
//

import SwiftUI


struct EventRow: View {
    
    static let spacing: CGFloat = 12

    let event: GoogleEvent
    
    @Environment(\.isFocused) var isFocused
    @Environment(\.timeColumnWidth) private var timeColumnWidth
    
    
    var body: some View {
        Button(action: { NSWorkspace.shared.open(event.htmlLink) }) {
            HStack(spacing: EventRow.spacing) {
                
                // Time
                HStack {
                    Text(formattedTimeText)
                        .font(.subheadline)
                        .foregroundStyle(
                            event.timeUntilEnd != nil
                            ? Color.accentColor : .primary
                        )
                        .background(timeWidthReader)
                }
                .alignmentGuide(.timeAlignmentGuide) { $0[.trailing] }
                .frame(minWidth: timeColumnWidth, alignment: .trailing)
                
                // Meeting title
                Text(event.summary ?? "Unnamed event")
                    .font(.subheadline)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Spacer()
                
                // Join conference
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
                
                // Open event
                Link(destination: event.htmlLink) {
                    Image(systemName: "chevron.right.circle")
                        .foregroundColor(.secondary)
                }
                .help("Open in Calendar")
                .buttonStyle(.plain)
                .focusable()
            }
        }
        .buttonStyle(.hover)
        .focusable()
    }
    
    private var timeWidthReader: some View {
        GeometryReader { geometry in
            Color.clear.preference(
                key: TimeWidthPreferenceKey.self,
                value: geometry.size.width
            )
        }
    }
    
    private var formattedTimeText: String {
        if let timeLeft = event.timeUntilEnd {
            return formatTimeLeft(
                hours: timeLeft.hours, minutes: timeLeft.minutes)
        }
        return event.formattedStartTime ?? ""
    }
    
    private func formatTimeLeft(hours: Int, minutes: Int) -> String {
        hours > 0
        ? "\(hours):\(String(format: "%02d", minutes)) left"
        : "\(minutes)m left"
    }
}

#Preview {
    @Previewable @State var timeColumnWidth: CGFloat = 0
    
    
    return VStack(spacing: 0) {
        VStack(alignment: .timeAlignmentGuide, spacing: 0) {
            EventMockData()
        }
        .onPreferenceChange(TimeWidthPreferenceKey.self) { width in
            timeColumnWidth = width
        }
        
        .environment(\.timeColumnWidth, timeColumnWidth)
    }
    .frame(width: 400)
    .padding()
}
