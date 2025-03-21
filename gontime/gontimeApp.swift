//
//  gontimeApp.swift
//  gontime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@google.com
//

import GoogleSignIn
import MenuBarExtraAccess
import SwiftUI

@main

struct gontimeApp: App {
  @State var isMenuPresented: Bool = false
  @StateObject private var appState = AppState()
  @StateObject private var updateService = UpdateService.shared
  @Environment(\.openSettings) private var openSettings

  // MARK: - Initialization

  /// Sets up initial app state and checks for updates

  @MainActor
  init() {
    let openSettingsAction = Environment(\.openSettings).wrappedValue
    Task {
      if await UpdateService.shared.checkForUpdates() {
        openSettingsAction()
        NSApplication.shared.activate(ignoringOtherApps: true)
      }
    }
  }

  // MARK: - Scene Configuration

  var body: some Scene {
    MenuBarExtra(
      content: {
        VStack(spacing: 0) {
          if case .signedIn = appState.authState {
            MenuView(isMenuPresented: $isMenuPresented)
              .environmentObject(appState)
          } else {
            Button("Sign In with Google") {
              Task {
                await appState.signIn()
              }
            }
          }
          Divider().padding(.vertical, 4)
          Button(
            appState.currentError != nil ? "⚠️\u{fe0f} Settings" : "Settings"
          ) {
            isMenuPresented = false
            openSettings()
            NSApplication.shared.activate(ignoringOtherApps: true)
          }
          Button("Quit") {
            NSApplication.shared.terminate(nil)
          }
        }.buttonStyle(.hover(height: 24))
          .padding(.horizontal, 10)
          .padding(.bottom, 4)
          .padding(.top, 8)
      },
      label: {
        HStack {
          Image(systemName: "calendar.badge.clock")
          Text(
            appState.currentError != nil
              ? "⚠️\u{fe0f} Calendar error" : appState.menuBarTitle)
        }
      }
    )
    .menuBarExtraStyle(.window)
    .menuBarExtraAccess(isPresented: $isMenuPresented)

    // Update window configuration
    WindowGroup("Update", id: "update") {
      if let updateInfo = updateService.updateAvailable {
        UpdateView(updateInfo: updateInfo)
      }
    }
    .defaultSize(width: 400, height: 250)
    .windowStyle(.hiddenTitleBar)

    // Settings window configuration
    Settings {
      SettingsView()
        .environmentObject(appState)
    }
  }
}
