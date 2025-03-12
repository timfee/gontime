//
//  Bundle+Extension.swift
//  gontime
//
//  Created by Tim Feeley on 2/21/25.
//

import SwiftUI

/// Bundle extension providing convenient access to common app information
extension Bundle {
    // MARK: - App Information
    
    /// The application's bundle name
    public var appName: String { getInfo("CFBundleName") }
    
    /// The user-visible display name of the app
    public var displayName: String { getInfo("CFBundleDisplayName") }
    
    /// The development region (primary language) of the app
    public var language: String { getInfo("CFBundleDevelopmentRegion") }
    
    /// The bundle identifier
    public var identifier: String { getInfo("CFBundleIdentifier") }
    
    /// The human-readable copyright notice, with properly formatted newlines
    public var copyright: String {
        getInfo("NSHumanReadableCopyright").replacingOccurrences(of: "\\n", with: "\n")
    }
    
    // MARK: - Version Information
    
    /// The build number of the app (typically incremental)
    public var appBuild: String { getInfo("CFBundleVersion") }
    
    /// The user-visible version number (semantic versioning)
    public var appVersionLong: String { getInfo("CFBundleShortVersionString") }
    
    // MARK: - Private Helpers
    
    /// Retrieves information from the bundle's info dictionary with a fallback warning symbol
    /// - Parameter key: The key to look up in the info dictionary
    /// - Returns: The value for the key or a warning symbol if not found
    private func getInfo(_ key: String) -> String {
        infoDictionary?[key] as? String ?? "⚠️"
    }
}
