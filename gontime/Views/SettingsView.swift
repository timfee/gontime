//
//  SettingsView.swift
//  gontime
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var errorManager: ErrorManager
    @StateObject private var settings = AppSettings.shared
    
    var body: some View {
        Form {
            // MARK: - Account Status
            Section("Account") {
                HStack {
                    Text("Status:")
                    switch authViewModel.state {
                    case .signedIn:
                        Text("Signed In")
                            .foregroundStyle(.green)
                    case .signedOut:
                        Text("Signed Out")
                            .foregroundStyle(.red)
                    case .signingIn:
                        Text("Signing In...")
                            .foregroundStyle(.orange)
                    }
                }
                
                if let error = errorManager.currentError {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.callout)
                }
            }
            
            // MARK: - Event Display Settings
            Section("Event Display") {
                Toggle("Hide all-day events", isOn: $settings.hideAllDayEvents)
                Toggle("Show event titles in menu bar", isOn: $settings.showEventTitlesInMenuBar)
                
                if settings.showEventTitlesInMenuBar {
                    Toggle("Clean event titles (remove text in brackets/parentheses)",
                           isOn: $settings.cleanEventTitles)
                    
                    Slider(
                        value: .init(
                            get: { Double(settings.maxEventTitleLength) },
                            set: { settings.maxEventTitleLength = Int($0) }
                        ),
                        in: 10...50,
                        step: 1
                    ) {
                        Text("Maximum title length: \(settings.maxEventTitleLength)")
                    }
                }
            }
        }
        .padding()
        .frame(width: 400)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthenticationViewModel())
        .environmentObject(ErrorManager.shared)
}

