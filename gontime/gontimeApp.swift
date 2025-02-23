//
//  gontimeApp.swift
//  gontime
//
//  Created by Tim Feeley on 2/20/25.
//

import GoogleSignIn
import MenuBarExtraAccess
import Sparkle
import SwiftUI

@main
struct gontimeApp: App {
    private let updaterController: SPUStandardUpdaterController

    @State var isMenuPresented: Bool = false

    @StateObject private var appState = AppState()
    @Environment(\.openSettings) private var openSettings

    init() {
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil
        )
    }

    var body: some Scene {
        MenuBarExtra(
            content: {
                VStack(spacing: 0) {
                    if case .signedIn = appState.authState {
                        MenuView(isMenuPresented: $isMenuPresented)
                            .environmentObject(appState)
                    } else {
                        Button("Sign In with Google", action: appState.signIn)
                    }

                    Divider().padding(.vertical, 4)

                    Button(
                        appState.currentError != nil ? "⚠️ Settings" : "Settings"
                    ) {
                        isMenuPresented = false
                        openSettings()
                        NSApplication.shared.activate(ignoringOtherApps: true)
                    }
                    CheckForUpdatesView(updater: updaterController.updater)
                        
                    Button("Quit") {
                        NSApplication.shared.terminate(nil)
                    }
                }.buttonStyle(.hover(height: 24))
                    .padding(.horizontal, 10)
                    .padding(.bottom, 4)
                    .padding(.top, 8)

            },
            label: {
                Text(
                    appState.currentError != nil
                        ? "⚠️ Calendar error" : appState.menuBarTitle)
            }
        )
        .menuBarExtraStyle(.window)
        .menuBarExtraAccess(isPresented: $isMenuPresented)

        Settings {
            SettingsView()
                .environmentObject(appState)
        }
    }
}
