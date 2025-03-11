//
//  SettingsView.swift
//  gontime
//

import Defaults
import LaunchAtLogin
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var updateService = UpdateService.shared
    @State private var showingUpdateSheet = false
    @Default(.showEventTitleInMenuBar) var showEventTitleInMenuBar: Bool
    @Default(.truncatedEventTitleLength) var truncatedEventTitleLength: Int
    @Default(.simplifyEventTitles) var simplifyEventTitles: Bool
    @Default(.meetingNotificationTime) var meetingNotificationTime: Int?
    
    var body: some View {
        VStack {
            Form {
                // MARK: - Account Status
                switch appState.authState {
                    case .signedIn(let user):
                        Section {
                            SignedInUserView(
                                user: user,
                                handleSignOut: appState.signOut
                            )
                        }
                    case .signedOut:
                        Section {
                            SignedOutUserView(handleSignIn: appState.signIn)
                        }
                }
                
                // MARK: - Event Filtering Settings
                Section {
                    Defaults.Toggle(
                        "Exclude all day events", key: .ignoreFullDayEvents)
                    Defaults.Toggle(
                        "Exclude events without attendees",
                        key: .ignoreEventsWithoutAttendees)
                }
                
                // Add Notification Settings section before Event Display section
                Section {
                    Picker("Meeting notifications", selection: $meetingNotificationTime) {
                        Text("Disabled").tag(nil as Int?)
                        ForEach([1, 2, 5, 10], id: \.self) { minutes in
                            Text("\(minutes) minutes before").tag(minutes as Int?)
                        }
                    }
                    .onChange(of: meetingNotificationTime) { oldValue, newValue in
                        if oldValue == nil && newValue != nil {
                            // Request permission when enabling notifications
                            Task { await NotificationManager.shared.requestAuthorization() }
                        }
                    }
                } header: {
                    Text("Notifications")
                }
                
                // MARK: - Event Display Settings
                Section {
                    Defaults.Toggle(
                        "Show event title in menu bar",
                        key: .showEventTitleInMenuBar)
                    if showEventTitleInMenuBar {
                        HStack {
                            Stepper(
                                value: $truncatedEventTitleLength, in: 10...50
                            ) {
                                Text("Limit event title length")
                            }
                            Text("\(truncatedEventTitleLength) characters")
                        }
                        Toggle(isOn: $simplifyEventTitles) {
                            Text("Clean up event titles")
                            Text(
                                "Removes brackets and parens to simplify titles"
                            )
                        }
                    }
                    
                }
                
                // MARK: - Start at login & version
                Section {
                    LaunchAtLogin.Toggle("Start at login")
                } footer: {
                    VStack(spacing: 4) {
                        Text("Version \(Bundle.main.appVersionLong)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let updateInfo = updateService.updateAvailable {
                            Button("Update available (Version \(String(format: "%.1f", updateInfo.latest)))") {
                                showingUpdateSheet = true
                            }
                            .buttonStyle(.link)
                            .font(.caption)
                            .foregroundColor(.accentColor)
                            .help("Download the latest version here")
                            .pointerStyle(.link)
                        }
                    }
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity)
                }
            }
            .animation(.spring(), value: showEventTitleInMenuBar)
            .formStyle(.grouped)
            .alert(
                "Error",
                isPresented: Binding(
                    get: { appState.currentError != nil },
                    set: { if !$0 { appState.clearError() } }
                )
            ) {
                Button("OK") { appState.clearError() }
            } message: {
                if let error = appState.currentError {
                    Text(error.localizedDescription)
                }
            }
        }
        .frame(minWidth: 400)
        .frame(width: 400)
        .frame(height: 450)
        .sheet(isPresented: $showingUpdateSheet) {
            if let updateInfo = updateService.updateAvailable {
                UpdateView(updateInfo: updateInfo)
                    .frame(width: 400, height: 250)
            }
        }
        .onReceive(updateService.$updateAvailable) { updateInfo in
            if updateInfo != nil {
                showingUpdateSheet = true
            }
        }
        .windowResizeBehavior(.automatic)
        
        
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
    
}
