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
/// This class ensures that:
///
/// 1. Only one notification is scheduled at a time (for the next upcoming event)
/// 2. Notifications, once triggered, are not modified
/// 3. Notifications are only rescheduled if the event time changes
/// 4. State is properly maintained across timer-based refreshes
/// 5. Handles last-minute events appropriately

final class NotificationManager: @unchecked Sendable {

  // MARK: - Singleton

  static let shared = NotificationManager()

  // MARK: - Private Properties

  /// Tracks whether we've already requested notification permissions

  private var hasRequestedPermission = false

  /// ID of the event that currently has a scheduled notification

  private var currentNotificationId: String?

  /// Scheduled time of the current notification
  /// Used to detect if an event's time has changed and needs rescheduling

  private var currentNotificationTime: Date?

  /// Reference to notification center to avoid repeated access

  private let notificationCenter: UNUserNotificationCenter

  // MARK: - Initialization

  private init() {
    self.notificationCenter = UNUserNotificationCenter.current()
    Task { await checkNotificationSettings() }
  }

  // MARK: - Public Methods

  /// Requests notification authorization if not already granted
  /// This is called both during initialization and when notification settings change

  @MainActor

  func requestAuthorization() async throws -> Bool {
    guard !hasRequestedPermission else { return true }
    hasRequestedPermission = true
    let options: UNAuthorizationOptions = [.alert]
    return try await notificationCenter.requestAuthorization(options: options)
  }

  /// Main entry point for notification management.
  /// Called by EventData's timer-based refresh cycle (every minute).
  /// Evaluates the next upcoming event and manages its notification.

  @MainActor

  func checkEventsForNotifications(_ events: [GoogleEvent]) async {
    do {
      // MARK: Early Exit: Notifications Disabled

      guard let minutes = Defaults[.meetingNotificationTime],
        minutes > 0
      else {
        Logger.debug("Notifications disabled or invalid notification time setting")
        return
      }

      // MARK: Early Exit: No Authorization

      let settings = await notificationCenter.notificationSettings()
      guard settings.authorizationStatus == .authorized else {
        Logger.debug("Notification authorization not granted")
        return
      }

      // MARK: Find Next Event and Handle State

      let now = Date()
      let nextEvent = findNextEvent(from: events, after: now)

      switch await handleEventState(nextEvent: nextEvent, minutes: minutes) {
      case .noEvents:

        clearState()
      case .eventStarted:

        clearState()
      case .lastMinute(let event):

        try await scheduleImmediateNotification(for: event)
        clearState()
      case .needsScheduling(let event, let notificationTime):

        try await handleEventScheduling(
          event: event,
          notificationTime: notificationTime,
          minutes: minutes
        )
      case .noChange:

        break
      }

    } catch {
      Logger.error("Notification handling failed", error: error)

      // Don't clear state on error - maintain last known good state
    }
  }

  // MARK: - Private Methods

  private func checkNotificationSettings() async {
    let settings = await notificationCenter.notificationSettings()
    if settings.authorizationStatus == .notDetermined,
      Defaults[.meetingNotificationTime] != nil
    {

      // Handle the result of authorization request
      if let granted = try? await requestAuthorization(), !granted {
        Logger.debug("Notification authorization denied")
      }
    }
  }

  private func findNextEvent(from events: [GoogleEvent], after date: Date) -> GoogleEvent? {
    events
      .filter { event in
        guard let startTime = event.startTime else { return false }
        return startTime > date
      }
      .min { ($0.startTime ?? date) < ($1.startTime ?? date) }
  }

  private enum EventState {
    case noEvents
    case eventStarted
    case lastMinute(GoogleEvent)
    case needsScheduling(GoogleEvent, Date)
    case noChange
  }

  private func handleEventState(nextEvent: GoogleEvent?, minutes: Int) async -> EventState {
    guard let event = nextEvent,
      let startTime = event.startTime
    else {
      return .noEvents
    }

    let now = Date()
    let notificationTime = startTime.addingTimeInterval(-Double(minutes * 60))

    if startTime <= now {
      return .eventStarted
    }

    if notificationTime <= now && startTime > now {
      return .lastMinute(event)
    }

    // If it's the same event with same time, no changes needed
    if event.id == currentNotificationId,
      let currentTime = currentNotificationTime,
      abs(currentTime.timeIntervalSince(notificationTime)) < 60
    {
      return .noChange
    }

    return .needsScheduling(event, notificationTime)
  }

  private func handleEventScheduling(
    event: GoogleEvent,
    notificationTime: Date,
    minutes: Int
  ) async throws {

    // If same event but time changed, or different event
    if let currentId = currentNotificationId {
      notificationCenter.removePendingNotificationRequests(withIdentifiers: [currentId])
    }

    try await scheduleNotification(for: event, at: notificationTime, minutes: minutes)
    currentNotificationId = event.id
    currentNotificationTime = notificationTime
  }

  private func clearState() {
    currentNotificationId = nil
    currentNotificationTime = nil
  }

  private func scheduleNotification(
    for event: GoogleEvent,
    at notificationTime: Date,
    minutes: Int
  ) async throws {
    let content = UNMutableNotificationContent()
    content.title = event.summary ?? "Untitled Event"
    content.body = "Starting in \(minutes) minutes"

    let components = Calendar.current.dateComponents(
      [.year, .month, .day, .hour, .minute],
      from: notificationTime
    )

    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
    let request = UNNotificationRequest(
      identifier: event.id,
      content: content,
      trigger: trigger
    )

    try await notificationCenter.add(request)
    Logger.debug(
      "Scheduled notification for '\(event.summary ?? "Untitled")' at \(notificationTime)")
  }

  private func scheduleImmediateNotification(for event: GoogleEvent) async throws {
    let content = UNMutableNotificationContent()
    content.title = event.summary ?? "Untitled Event"
    content.body = "Starting soon"

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    let request = UNNotificationRequest(
      identifier: event.id,
      content: content,
      trigger: trigger
    )

    try await notificationCenter.add(request)
    Logger.debug("Scheduled immediate notification for '\(event.summary ?? "Untitled")'")
  }
}
