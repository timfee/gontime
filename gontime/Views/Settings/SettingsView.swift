//
//  SettingsView.swift
//  gontime
//

import Defaults
import LaunchAtLogin
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Default(.showEventTitleInMenuBar) var showEventTitleInMenuBar: Bool
    @Default(.truncatedEventTitleLength) var truncatedEventTitleLength: Int
    @Default(.simplifyEventTitles) var simplifyEventTitles: Bool
    
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
                    Defaults.Toggle("Exclude all day events", key: .ignoreFullDayEvents)
                    Defaults.Toggle("Exclude events without attendees", key: .ignoreEventsWithoutAttendees)
                }
                
                // MARK: - Event Display Settings
                Section {
                    Defaults.Toggle("Show event title in menu bar", key: .showEventTitleInMenuBar)
                    if(showEventTitleInMenuBar) {
                        HStack {
                            Stepper(value: $truncatedEventTitleLength, in: 10...50) {
                                Text("Limit event title length")
                            }
                            Text("\(truncatedEventTitleLength) characters")
                        }
                        Toggle(isOn: $simplifyEventTitles) {
                            Text("Clean up event titles")
                            Text("Removes brackets and parens to simplify titles")
                        }
                    }
                    
                }
                
                // MARK: - Start at login & version
                Section {
                    LaunchAtLogin.Toggle("Start at login")
                }
                
                
                Text("Version \(Bundle.main.appVersionLong)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top,10)
            }
            .animation(.spring(), value: showEventTitleInMenuBar)
            .formStyle(.grouped)
            .alert(
                "Error",
                isPresented: Binding(
                    get: { appState.currentError != nil },
                    set: { if !$0 { appState.dismissError() } }
                )
            ) {
                Button("OK") {
                    appState.dismissError()
                }
            } message: {
                if let error = appState.currentError {
                    Text(error)
                }
            }
            
            

        }
        .frame(width: 400)
   
        
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
