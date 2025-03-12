//
//  gontimeApp.swift
//  gOnTime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@ (Tim Feeley)
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
            appState.currentError != nil ? "⚠️ Settings" : "Settings"
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
        Text(
          appState.currentError != nil
            ? "⚠️ Calendar error" : appState.menuBarTitle)
      }
    )
    .menuBarExtraStyle(.window)
    .menuBarExtraAccess(isPresented: $isMenuPresented)
    WindowGroup("Update", id: "update") {
      if let updateInfo = updateService.updateAvailable {
        UpdateView(updateInfo: updateInfo)
      }
    }
    .defaultSize(width: 400, height: 250)
    .windowStyle(.hiddenTitleBar)
    Settings {
      SettingsView()
        .environmentObject(appState)
    }
  }
}
