//
//  Views/Menu/MenuView.swift
//  gOnTime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@ (Tim Feeley)
//

import SwiftUI

struct MenuView: View {
  @EnvironmentObject var appState: AppState
  @Environment(\.openSettings) private var openSettings
  @Binding var isMenuPresented: Bool
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
#Preview {
  MenuView(isMenuPresented: .constant(true))
    .environmentObject(AppState())
    .frame(width: 400)
    .padding(24)
}
