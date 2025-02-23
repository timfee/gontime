//
//  ContentView.swift
//  gontime
//
//  Created by Tim Feeley on 2/20/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            if case .signedIn = appState.authState {
                signedInContent
            } else {
                Button("Sign In with Google", action: appState.signIn)
            }
        }
        .frame(width: 300)
        .padding()
    }
    
    @ViewBuilder
    private var signedInContent: some View {
        Text("Today's Events")
            .font(.headline)
            .padding(.bottom, 8)
        
        if appState.events.isEmpty {
            Text("No upcoming events today")
                .foregroundColor(.secondary)
                .padding()
        } else {
            List(appState.events) { event in
                EventRow(event: event)
                    .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
            }
            .listStyle(.plain)
        }
        
        Button("Sign Out", action: appState.signOut)
            .padding(.top, 8)
    }
}

struct EventRow: View {
    let event: GoogleEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(event.summary ?? "Unnamed event")
                .font(.headline)
                .lineLimit(2)
            
            if let timeRange = event.formattedTimeRange {
                Text(timeRange)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 12) {
                if let link = event.htmlLink,
                   let url = URL(string: link) {
                    Link("View", destination: url)
                        .font(.footnote)
                }
                
                if let hangoutLink = event.hangoutLink,
                   let url = URL(string: hangoutLink),
                   (event.isInProgress || event.isUpcoming) {
                    Link("Join Meeting", destination: url)
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(event.isInProgress ? Color.blue.opacity(0.1) : Color.clear)
        )
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
