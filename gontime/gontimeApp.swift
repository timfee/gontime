//
//  gontimeApp.swift
//  gontime
//
//  Created by Tim Feeley on 2/20/25.
//

import SwiftUI
import GoogleSignIn
import MenuBarExtraAccess

@main
struct gontimeApp: App {
    @State var isMenuPresented: Bool = false
    
    @StateObject private var appState = AppState()
    @Environment(\.openSettings) private var openSettings
    
    var body: some Scene {
        MenuBarExtra(content: {
            VStack(spacing: 0) {
                if case .signedIn = appState.authState {
                    MenuView(isMenuPresented: $isMenuPresented)
                        .environmentObject(appState)
                } else {
                    Button("Sign In with Google", action: appState.signIn)
                }
                
                Divider().padding(.vertical, 4)
                
                Button(appState.currentError != nil ? "⚠️ Settings" : "Settings") {
                    isMenuPresented = false
                    openSettings()
                }
                
                
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }.buttonStyle(.hover(height: 24))
                .padding(.horizontal, 10)
                .padding(.bottom, 4)
                .padding(.top, 8)
            
        }, label: {
            Text(appState.currentError != nil ? "⚠️ Calendar error" : appState.menuBarTitle)
        })
        .menuBarExtraStyle(.window)
        .menuBarExtraAccess(isPresented: $isMenuPresented)
        
        Settings {
            SettingsView()
                .environmentObject(appState)
        }
    }
}
