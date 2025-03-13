//
//  Bundle+Extension.swift
//  gontime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@google.com
//

import SwiftUI

// MARK: - Bundle Information Access

extension Bundle {
  // MARK: App Information Properties

  /// The application name from the bundle

  public var appName: String { getInfo("CFBundleName") }

  /// The user-visible display name

  public var displayName: String { getInfo("CFBundleDisplayName") }

  /// The development region (primary language)

  public var language: String { getInfo("CFBundleDevelopmentRegion") }

  /// The bundle identifier

  public var identifier: String { getInfo("CFBundleIdentifier") }

  /// The formatted copyright notice

  public var copyright: String {
    getInfo("NSHumanReadableCopyright").replacingOccurrences(of: "\\n", with: "\n")
  }

  // MARK: Version Information

  /// The build number

  public var appBuild: String { getInfo("CFBundleVersion") }

  /// The marketing version number

  public var appVersionLong: String { getInfo("CFBundleShortVersionString") }

  // MARK: - Private Helper

  /// Safely retrieves info dictionary values with a fallback

  private func getInfo(_ key: String) -> String {
    infoDictionary?[key] as? String ?? "⚠️"
  }
}
