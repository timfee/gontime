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

/// Manages local notifications for upcoming calendar events

final class NotificationManager {

  // MARK: - Singleton

  static let shared = NotificationManager()

  // MARK: - Private Properties

  private var hasRequestedPermission = false

  // MARK: - Initialization

  private init() {
    Task { await checkNotificationSettings() }
  }

  // MARK: - Public Methods

  /// Requests notification authorization if not already granted

  @MainActor

  func requestAuthorization() async throws {
    guard !hasRequestedPermission else { return }
    hasRequestedPermission = true
    let options: UNAuthorizationOptions = [.alert]
    try await UNUserNotificationCenter.current().requestAuthorization(options: options)
  }

  /// Evaluates events and schedules notifications as needed

  @MainActor

  func checkEventsForNotifications(_ events: [GoogleEvent]) async {
    Logger.debug("Starting notification check for \(events.count) events")
    do {
      guard let minutes = Defaults[.meetingNotificationTime],
        minutes > 0
      else {
        Logger.debug("Notifications disabled or invalid time setting")
        await clearAllNotifications()
        return
      }

      let settings = await UNUserNotificationCenter.current().notificationSettings()
      guard settings.authorizationStatus == .authorized else {
        Logger.debug("Notification authorization not granted")
        return
      }

      let now = Date()
      let upcomingEvents = findUpcomingEvents(from: events, after: now, minutes: minutes)
      Logger.debug("Found \(upcomingEvents.count) upcoming events requiring notifications")

      if upcomingEvents.isEmpty {
        if await pendingNotificationsExist() {
          Logger.debug("Clearing existing notifications as no upcoming events found")
          await clearAllNotifications()
        }
        return
      }

      // Schedule notifications for upcoming events
      for event in upcomingEvents {
        Logger.debug("Processing notifications for event: \(event.summary ?? "Untitled")")
        try await handleNotificationForEvent(event, minutes: minutes)
      }

    } catch {
      Logger.error("Notification handling failed", error: error)
    }
  }

  // MARK: - Private Methods

  private func checkNotificationSettings() async {
    let settings = await UNUserNotificationCenter.current().notificationSettings()
    if settings.authorizationStatus == .notDetermined,
      Defaults[.meetingNotificationTime] != nil
    {
      try? await requestAuthorization()
    }
  }

  private func findUpcomingEvents(from events: [GoogleEvent], after date: Date, minutes: Int)
    -> [GoogleEvent]
  {
    events
      .filter { event in
        guard let startTime = event.startTime else { return false }
        let notificationTime = startTime.addingTimeInterval(
          -Double(minutes * 60))
        return startTime > date && notificationTime > date
      }
      .sorted { $0.startTime ?? date < $1.startTime ?? date }
  }

  private func handleNotificationForEvent(_ event: GoogleEvent, minutes: Int) async throws {
    guard let startTime = event.startTime else { return }
    let notificationTime = startTime.addingTimeInterval(-Double(minutes * 60))

    if await !shouldRescheduleNotification(for: event, at: notificationTime) {
      return
    }

    await clearAllNotifications()
    try await scheduleNotification(for: event, minutes: minutes)
  }

  private func shouldRescheduleNotification(for event: GoogleEvent, at expectedTime: Date) async
    -> Bool
  {
    let pendingRequests = await UNUserNotificationCenter.current().pendingNotificationRequests()

    guard let existingRequest = pendingRequests.first(where: { $0.identifier == event.id }),
      let trigger = existingRequest.trigger as? UNCalendarNotificationTrigger,
      let scheduledDate = Calendar.current.date(from: trigger.dateComponents)
    else {
      return true
    }

    return abs(scheduledDate.timeIntervalSince(expectedTime)) >= 60
  }

  private func clearAllNotifications() async {
    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
  }

  private func pendingNotificationsExist() async -> Bool {
    let pendingRequests = await UNUserNotificationCenter.current().pendingNotificationRequests()
    return !pendingRequests.isEmpty
  }

  private func scheduleNotification(for event: GoogleEvent, minutes: Int) async throws {
    guard let startTime = event.startTime else { return }
    let notificationTime = startTime.addingTimeInterval(-Double(minutes * 60))

    let components = Calendar.current.dateComponents(
      [.year, .month, .day, .hour, .minute],
      from: notificationTime
    )

    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
    let content = UNMutableNotificationContent()
    content.title = event.summary ?? "Untitled Event"
    content.body = "Starting in \(minutes) minutes"

    let request = UNNotificationRequest(
      identifier: event.id,
      content: content,
      trigger: trigger
    )

    try await UNUserNotificationCenter.current().add(request)
    Logger.debug(
      "Scheduled notification for next event: \(event.summary ?? "event") at \(notificationTime)")
  }
}
