//
//  NotificationManager.swift
//  gontime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@google.com
//

import Defaults
import UserNotifications

/// Manages local notifications for upcoming calendar events.
/// Coordinates with EventData's minute-aligned refresh cycle for precise notification timing.
///
/// Design Notes:
/// - Works with EventData's :00 second refresh cycle for precise timing
/// - Maintains exactly one notification for the next upcoming event
/// - Uses event etags to detect genuine content changes
/// - Preserves fired notifications (never removes them)
/// - Handles notification permissions via SettingsView

final class NotificationManager: @unchecked Sendable {

  // MARK: - Properties

  /// Shared instance for application-wide notification management

  static let shared = NotificationManager()

  /// Interface to system notification services

  private let notificationCenter = UNUserNotificationCenter.current()

  /// Tracks whether we've requested permission during this session

  private var hasRequestedPermission = false

  /// Currently scheduled notification state
  /// Used to detect genuine changes and avoid unnecessary updates

  private var scheduledNotification: (id: String, etag: String)?

  // MARK: - Initialization

  private init() {}

  // MARK: - Public Interface

  /// Updates notification for the next upcoming event if needed
  /// Called by EventData during its minute-aligned refresh cycle
  ///
  /// - Parameter events: Array of calendar events to evaluate
  /// - Note: EventData ensures this is called at :00 seconds each minute

  @MainActor

  func checkEventsForNotifications(_ events: [GoogleEvent]) async {

    // Early exit if notifications aren't enabled
    guard let minutes = Defaults[.meetingNotificationTime],
      minutes > 0,
      await notificationCenter.notificationSettings().authorizationStatus == .authorized
    else { return }

    // Find the next event that hasn't started
    guard
      let nextEvent =
        events
        .filter({ $0.startTime?.timeIntervalSinceNow ?? -1 > 0 })
        .min(by: { ($0.startTime ?? .distantFuture) < ($1.startTime ?? .distantFuture) })
    else { return }

    // Only update if the event details have changed
    let needsUpdate =
      scheduledNotification.map { current in
        nextEvent.id != current.id || nextEvent.etag != current.etag
      } ?? true

    if needsUpdate {
      await scheduleNotification(for: nextEvent, minutes: minutes)
    }
  }

  /// Requests notification authorization if not already granted
  /// Called by SettingsView when enabling notifications
  ///
  /// - Returns: Boolean indicating if authorization was granted
  /// - Throws: System authorization errors

  @MainActor

  func requestAuthorization() async throws -> Bool {
    hasRequestedPermission = true
    return try await notificationCenter.requestAuthorization(options: [.alert])
  }

  // MARK: - Private Implementation

  /// Schedules a notification for an event
  ///
  /// - Parameters:
  ///   - event: The event to notify about
  ///   - minutes: How many minutes before the event to notify

  private func scheduleNotification(
    for event: GoogleEvent,
    minutes: Int
  ) async {
    guard let startTime = event.startTime else { return }

    // Remove existing notification if we have one
    if let current = scheduledNotification {
      notificationCenter.removePendingNotificationRequests(withIdentifiers: [current.id])
    }

    // Calculate exact notification time
    let notificationTime =
      Calendar.current.date(
        byAdding: .minute,
        value: -minutes,
        to: startTime
      ) ?? startTime

    // Create notification content
    let content = UNMutableNotificationContent()
    content.title = event.summary ?? "Untitled Event"
    content.body = "Starting in \(minutes) minutes"

    // Use calendar trigger for precise timing
    let components = Calendar.current.dateComponents(
      [.year, .month, .day, .hour, .minute],
      from: notificationTime
    )
    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

    // Schedule the notification
    let request = UNNotificationRequest(
      identifier: event.id,
      content: content,
      trigger: trigger
    )

    do {
      try await notificationCenter.add(request)
      scheduledNotification = (event.id, event.etag)
      Logger.debug(
        "Scheduled notification for '\(event.summary ?? "Untitled")' at \(notificationTime)")
    } catch {
      Logger.error("Failed to schedule notification", error: error)
    }
  }
}
