//
//  UpdateService.swift
//  gontime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@google.com
//

import Foundation
import SwiftUI
import os.log

// MARK: - Update Information Model

/// Represents version update information from remote source

struct UpdateInfo: Codable {
  let latest: Double
  let message: String
  let url: String
  let force: Bool
}

// MARK: - Update Service

/// Manages application update checks and notifications
@MainActor
final class UpdateService: ObservableObject {

  // MARK: - Singleton

  static let shared = UpdateService()

  // MARK: - Published Properties

  @Published private(set) var updateAvailable: UpdateInfo?

  // MARK: - Private Properties

  private let updateURL = URL(
    string: "https://raw.githubusercontent.com/timfee/gontime_updates/refs/heads/main/version.json")!

  private init() {}

  // MARK: - Public Methods

  /// Checks for available updates
  /// - Returns: Boolean indicating if an update is available

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
        Logger.debug(
          "No update available (current: \(currentVersion), latest: \(updateInfo.latest))")
      }

      return hasUpdate
    } catch {
      Logger.error("Failed to check for updates", error: error)
      return false
    }
  }
}
