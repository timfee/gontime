import Foundation
import SwiftUI

struct UpdateInfo: Codable {
    let latest: Double
    let message: String
    let url: String
    let force: Bool
}

@MainActor
class UpdateService: ObservableObject {
    static let shared = UpdateService()
    
    @Published var updateAvailable: UpdateInfo?
    
    private let updateURL = "https://raw.githubusercontent.com/timfee/gontime_updates/refs/heads/main/version.json"
    
    // Modified to return bool indicating if update is available
    func checkForUpdates() async -> Bool {
        guard let url = URL(string: updateURL) else { return false }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let updateInfo = try JSONDecoder().decode(UpdateInfo.self, from: data)
            
            let currentVersion = Double(Bundle.main.appVersionLong) ?? 0.0
            
            if updateInfo.latest > currentVersion {
                self.updateAvailable = updateInfo
                return true
            }
        } catch {
            print("Error checking for updates: \(error)")
        }
        return false
    }
}
