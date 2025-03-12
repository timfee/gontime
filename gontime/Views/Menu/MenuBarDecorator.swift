//
//  Views/Menu/MenuBarDecorator.swift
//  gOnTime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@ (Tim Feeley)
//

import Combine
import Defaults
import Foundation

protocol MenuBarTitleGenerator {
  func generateTitle(error: String?, events: [GoogleEvent]) -> String
}
final class MenuBarDecorator: MenuBarTitleGenerator {
  private enum Constants {
    static let error = "⚠\u{fef} Calendar error"
    static let allClear = "All clear"
    static let untitled = "Untitled Event"
    static let nextMeeting = "next meeting"
    static let now = "Now"
  }
  func generateTitle(error: String?, events: [GoogleEvent]) -> String {
    if error != nil { return Constants.error }
    guard let event = events.first else { return Constants.allClear }
    return generateEventStatus(for: event)
  }
  private var cancellables = Set<AnyCancellable>()
  private func generateEventStatus(for event: GoogleEvent) -> String {
    let title =
      Defaults[.showEventTitleInMenuBar]
      ? simplifyTitle(event.summary ?? Constants.untitled)
      : Constants.nextMeeting
    if event.isInProgress {
      return Defaults[.showEventTitleInMenuBar] ? "\(Constants.now): \(title)" : Constants.now
    }
    guard let timeUntil = event.timeUntilStart else { return Constants.allClear }
    return timeUntil.hours > 0
      ? "\(timeUntil.hours)h until \(title)"
      : "\(timeUntil.minutes)m until \(title)"
  }
  private func simplifyTitle(_ title: String) -> String {
    var result = title
    if Defaults[.simplifyEventTitles] {
      result =
        result
        .replacingOccurrences(of: "\\[.*?\\]|\\(.*?\\)", with: "", options: .regularExpression)
        .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        .trimmingCharacters(in: .whitespaces)
    }
    let maxLength = Defaults[.truncatedEventTitleLength]
    if result.count > maxLength {
      result = String(result.prefix(maxLength - 1)) + "…"
    }
    return result
  }
}
