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

// MARK: - GitHub API Error

enum GitHubAPIError: LocalizedError {
  case rateLimitExceeded
  case invalidResponse

  var errorDescription: String? {
    switch self {
    case .rateLimitExceeded:
      return "GitHub API rate limit exceeded. Please try again later."
    case .invalidResponse:
      return "Unable to fetch update information."
    }
  }
}

// MARK: - GitHub Release Response Models

struct GitHubRelease: Codable {
  let tagName: String
  let body: String
  let htmlUrl: String
  let prerelease: Bool

  enum CodingKeys: String, CodingKey {
    case tagName = "tag_name"
    case body
    case htmlUrl = "html_url"
    case prerelease
  }
}

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

  private let apiURL = URL(
    string: "https://api.github.com/repos/timfee/gontime_updates/releases/latest")!

  private init() {}

  // MARK: - Public Methods

  /// Checks for available updates
  /// - Returns: Boolean indicating if an update is available

  func checkForUpdates() async -> Bool {
    do {
      var request = URLRequest(url: apiURL)
      request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
      request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
      request.setValue("Gontime/\(Bundle.main.appVersionLong)", forHTTPHeaderField: "User-Agent")

      let (data, response) = try await URLSession.shared.data(for: request)

      guard let httpResponse = response as? HTTPURLResponse else {
        throw GitHubAPIError.invalidResponse
      }

      guard httpResponse.statusCode == 200 else {
        Logger.error("HTTP error: \(httpResponse.statusCode)")
        throw GitHubAPIError.invalidResponse
      }

      let release = try JSONDecoder().decode(GitHubRelease.self, from: data)
      let currentVersion = Double(Bundle.main.appVersionLong) ?? 0.0

      let versionString = release.tagName.trimmingCharacters(in: CharacterSet(charactersIn: "v"))
      guard let latestVersion = Double(versionString) else {
        Logger.error("Invalid version format: \(release.tagName)")
        return false
      }

      let hasUpdate = latestVersion > currentVersion

      if hasUpdate {
        Logger.state("Update available: \(latestVersion) (current: \(currentVersion))")
        self.updateAvailable = UpdateInfo(
          latest: latestVersion,
          message: release.body,
          url: release.htmlUrl,
          force: release.prerelease
        )
      } else {
        Logger.debug("No update available (current: \(currentVersion), latest: \(latestVersion))")
      }

      return hasUpdate
    } catch {
      Logger.error("Failed to check for updates", error: error)
      return false
    }
  }
}
