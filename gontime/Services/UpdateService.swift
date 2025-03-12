import Foundation
import SwiftUI
import os.log

/// Model representing update information from the remote endpoint
struct UpdateInfo: Codable {
    let latest: Double
    let message: String
    let url: String
    let force: Bool
}

/// Service responsible for checking and managing application updates
@MainActor
final class UpdateService: ObservableObject {
    // MARK: - Properties
    
    static let shared = UpdateService()
    
    @Published private(set) var updateAvailable: UpdateInfo?
    
    private let updateURL = URL(string: "https://raw.githubusercontent.com/timfee/gontime_updates/refs/heads/main/version.json")!
    
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Checks for available updates by comparing the current version against the remote version
    /// - Returns: Boolean indicating whether an update is available
    func checkForUpdates() async -> Bool {
        do {
            let (data, _) = try await URLSession.shared.data(from: updateURL)
            let updateInfo = try JSONDecoder().decode(UpdateInfo.self, from: data)
            let currentVersion = Double(Bundle.main.appVersionLong) ?? 0.0
            
            let hasUpdate = updateInfo.latest > currentVersion
            if hasUpdate {
                Logger.state("Update available: \(updateInfo.latest) (current: \(currentVersion))")
                self.updateAvailable = updateInfo
            } else {
                Logger.debug("No update available (current: \(currentVersion), latest: \(updateInfo.latest))")
            }
            return hasUpdate
        } catch {
            Logger.error("Failed to check for updates", error: error)
            return false
        }
    }
}
