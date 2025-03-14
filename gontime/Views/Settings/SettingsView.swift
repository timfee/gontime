//
//  SettingsView.swift
//  gontime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@google.com
//

import Defaults
import LaunchAtLogin
import SwiftUI
import UserNotifications

// MARK: - Settings View

/// Main settings view providing user configuration options
struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var updateService = UpdateService.shared
    @State private var showingUpdateSheet = false
    
    // MARK: - User Preferences
    
    @Default(.showEventTitleInMenuBar) var showEventTitleInMenuBar: Bool
    @Default(.truncatedEventTitleLength) var truncatedEventTitleLength: Int
    @Default(.simplifyEventTitles) var simplifyEventTitles: Bool
    @Default(.meetingNotificationTime) var meetingNotificationTime: Int?
    @State private var notificationAuthStatus: UNAuthorizationStatus?
    
    // MARK: - View Components
    
    /// Notification settings section with permission handling
    
    @ViewBuilder
    private var notificationSection: some View {
        Section {
            if let status = notificationAuthStatus, status == .denied {
                HStack {
                    Text("Notifications are disabled in System Settings")
                        .foregroundColor(.secondary)
                    Button("Open Settings") {
                        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.notifications")!)
                    }
                    .buttonStyle(.link)
                }
            } else {
                Picker("Meeting notifications", selection: $meetingNotificationTime) {
                    Text("Disabled").tag(nil as Int?)
                    ForEach([1, 2, 5, 10], id: \.self) { minutes in
                        Text("\(minutes) minutes before").tag(minutes as Int?)
                    }
                }
            }
        } header: {
            Text("Notifications")
        }
        .onChange(of: meetingNotificationTime) { _, newValue in
            Task {
                await handleNotificationChange(to: newValue)
            }
        }
        .task {
            await checkNotificationStatus()
        }
    }
    
    /// Event display configuration section
    
    @ViewBuilder
    private var eventDisplaySection: some View {
        Section {
            Defaults.Toggle(
                "Show event title in menu bar",
                key: .showEventTitleInMenuBar)
            if showEventTitleInMenuBar {
                EventTitleSettings(
                    truncatedLength: $truncatedEventTitleLength,
                    simplifyTitles: $simplifyEventTitles
                )
            }
        }
    }
    
    /// Version information footer with update availability
    
    @ViewBuilder
    private var versionFooter: some View {
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
    
    // MARK: - Notification Handling
    
    /// Checks current notification authorization status
    private func checkNotificationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        await MainActor.run {
            notificationAuthStatus = settings.authorizationStatus
            
            // If notifications are denied, disable the setting
            if settings.authorizationStatus == .denied {
                meetingNotificationTime = nil
            }
        }
    }
    
    /// Handles notification permission requests when enabling notifications
    private func handleNotificationChange(to newValue: Int?) async {
        guard newValue != nil else { return }
        
        do {
            // Request authorization and handle the result
            if try await NotificationManager.shared.requestAuthorization() {
                // Authorization granted, update status
                await checkNotificationStatus()
            } else {
                // Authorization denied, reset to disabled
                await MainActor.run {
                    meetingNotificationTime = nil
                }
            }
        } catch {
            Logger.error("Failed to request notification authorization", error: error)
            await MainActor.run {
                meetingNotificationTime = nil
            }
        }
    }
    
    // MARK: - View Body
    
    var body: some View {
        VStack {
            Form {
                switch appState.authState {
                    case .signedIn(let user):
                        Section {
                            SignedInUserView(
                                user: user,
                                handleSignOut: { Task { appState.signOut() } }
                            )
                        }
                    case .signedOut:
                        Section {
                            SignedOutUserView(
                                handleSignIn: { Task { await appState.signIn() } }
                            )
                        }
                }
                Section {
                    Defaults.Toggle(
                        "Exclude all day events", key: .ignoreFullDayEvents)
                    Defaults.Toggle(
                        "Exclude events without attendees",
                        key: .ignoreEventsWithoutAttendees)
                }
                notificationSection
                eventDisplaySection
                Section {
                    LaunchAtLogin.Toggle("Start at login")
                } footer: {
                    versionFooter
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

// MARK: - Event Title Settings View

/// Configuration view for event title display options

private struct EventTitleSettings: View {
    @Binding var truncatedLength: Int
    @Binding var simplifyTitles: Bool
    
    var body: some View {
        HStack {
            Stepper(
                value: $truncatedLength, in: 10...50
            ) {
                Text("Limit event title length")
            }
            Text("\(truncatedLength) characters")
        }
        
        Toggle(isOn: $simplifyTitles) {
            Text("Clean up event titles")
            Text(
                "Removes brackets and parens to simplify titles"
            )
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
