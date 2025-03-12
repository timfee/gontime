//
//  MenuView.swift
//  gOnTime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@ (Tim Feeley)
//

import SwiftUI

// MARK: - Menu View
/// Main menu view displaying event list or empty state
struct MenuView: View {
    // MARK: - Properties
    
    @EnvironmentObject var appState: AppState
    @Environment(\.openSettings) private var openSettings
    @Binding var isMenuPresented: Bool
    
    // MARK: - View Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if appState.events.isEmpty {
                Text("No upcoming events today")
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
            } else {
                ForEach(appState.events) { event in
                    EventRow(event: event)
                }
            }
        }
    }
}

// MARK: - Previews
#Preview {
    MenuView(isMenuPresented: .constant(true))
        .environmentObject(AppState())
        .frame(width: 400)
        .padding(24)
}
