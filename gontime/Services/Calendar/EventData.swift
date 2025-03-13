//
//  EventData.swift
//  gontime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@google.com
//

import Combine
import Foundation
import SwiftUI

/// Manages calendar event data and scheduling, including refresh timers and system notifications
@MainActor
final class EventData: ObservableObject {

  // MARK: - Constants

  private enum Constants {
    static let refreshInterval: TimeInterval = 60
  }

  // MARK: - Published Properties

  /// Currently loaded calendar events
  @Published private(set) var events: [GoogleEvent] = []

  /// Timestamp of the last successful data refresh
  @Published private(set) var lastRefreshDate: Date? = nil

  // MARK: - Private Properties

  private var currentTimer: Timer?
  private let calendarService: CalendarDataService
  private var isActive = false
  private var workspaceNotificationObserver: NSObjectProtocol?
  private var appActivationObserver: NSObjectProtocol?
  private var lastScheduledMinute: Int = -1
  private let notificationManager = NotificationManager.shared

  // MARK: - Lifecycle

  init(calendarService: CalendarDataService) {
    Logger.debug("Initializing EventData")
    self.calendarService = calendarService
    setupObservers()
  }

  deinit {

    // Since the class is @MainActor, we can assert we're on the main actor
    MainActor.assumeIsolated {
      cleanup()
    }
  }

  // MARK: - Public Methods

  /// Starts event monitoring and schedules the initial refresh timer

  func start() {
    Logger.debug("Starting EventData")
    isActive = true
    scheduleNextMinuteRefresh()

    Task {
      Logger.debug("Performing initial refresh on start")
      try? await refresh()
    }

  }

  /// Stops event monitoring and cleans up resources

  func stop() {
    Logger.debug("Stopping EventData")
    isActive = false
    if let lastRefresh = lastRefreshDate {
      let activeTime = Date().timeIntervalSince(lastRefresh)
      Logger.state(
        "EventData stopping after \(String(format: "%.1f", activeTime))s since last refresh")
    }
    cancelCurrentTimer()
  }

  /// Fetches latest events and updates notifications
  /// - Throws: AppError if the refresh operation fails

  func refresh() async throws {
    let now = Date()
    Logger.debug("Starting refresh at: \(now)")

    if let last = lastRefreshDate {
      let timeSinceLast = now.timeIntervalSince(last)
      Logger.debug("Time since last refresh: \(String(format: "%.1f", timeSinceLast))s")
    }

    do {
      let fetchedEvents = try await calendarService.fetchEvents()
      Logger.state("Fetched \(fetchedEvents.count) events")
      events = fetchedEvents
      lastRefreshDate = now

      // Log next event timing if available
      if let nextEvent = fetchedEvents.first,
        let startTime = nextEvent.startTime
      {
        let timeUntil = startTime.timeIntervalSince(now)
        if timeUntil > 0 {
          Logger.debug("Next event starts in: \(String(format: "%.1f", timeUntil))s")
        } else if let endTime = nextEvent.endTime,
          endTime > now
        {
          Logger.debug(
            "Current event ends in: \(String(format: "%.1f", endTime.timeIntervalSince(now)))s")
        }
      } else {
        Logger.debug("No upcoming events found")
      }

      Logger.debug("Checking events for notifications")
      await notificationManager.checkEventsForNotifications(events)
    } catch {
      Logger.error("Refresh failed", error: error)
      self.events = []
      throw error as? AppError ?? .calendar(error)
    }
  }

  // MARK: - Timer Management

  private func scheduleNextMinuteRefresh() {
    cancelCurrentTimer()
    guard isActive else {
      Logger.debug("Not scheduling refresh - EventData inactive")
      return
    }

    let calendar = Calendar.current
    let now = Date()

    let currentSecond = calendar.component(.second, from: now)
    Logger.debug("Current time position: second \(currentSecond)")

    // Calculate next minute boundary for precise timing
    var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
    components.second = 0

    guard let targetDate = calendar.date(from: components) else {
      Logger.error("Failed to create target date for refresh")
      return
    }

    // Prevent duplicate timer scheduling within the same minute
    let currentMinute = calendar.component(.minute, from: now)
    if currentMinute == lastScheduledMinute {
      Logger.debug("Already scheduled refresh for minute: \(currentMinute)")
      return
    }

    lastScheduledMinute = currentMinute
    let delay = targetDate.timeIntervalSince(now)
    Logger.debug("Scheduling refresh with \(delay) second delay")
    Logger.debug("Scheduling next refresh for: \(targetDate)")

    currentTimer = Timer(fire: targetDate, interval: 0, repeats: false) { [weak self] _ in
      Task { @MainActor in
        guard let self else { return }
        guard self.isActive else { return }

        let actualSecond = calendar.component(.second, from: Date())
        Logger.debug("Timer executed at second: \(actualSecond)")

        Logger.debug("Executing scheduled refresh")
        try? await self.refresh()
        self.scheduleNextMinuteRefresh()
      }
    }

    if let timer = currentTimer {
      RunLoop.main.add(timer, forMode: .common)
    }
  }

  private func cancelCurrentTimer() {
    Logger.debug("Cancelling current timer")
    currentTimer?.invalidate()
    currentTimer = nil
  }

  // MARK: - System Notification Handling

  private func setupObservers() {
    Logger.debug("Setting up system observers")

    // Handle system wake events to ensure timer accuracy
    workspaceNotificationObserver = NSWorkspace.shared.notificationCenter.addObserver(
      forName: NSWorkspace.didWakeNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      Task { @MainActor in
        guard let self else { return }
        guard self.isActive else { return }

        Logger.state("System woke from sleep - rescheduling timers")
        self.lastScheduledMinute = -1
        self.scheduleNextMinuteRefresh()
        try? await self.refresh()
      }
    }

    // Verify timer validity when app becomes active
    appActivationObserver = NSWorkspace.shared.notificationCenter.addObserver(
      forName: NSApplication.didBecomeActiveNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      Task { @MainActor in
        guard let self else { return }
        guard self.isActive else { return }

        Logger.state("App became active - verifying timer")

        if self.currentTimer == nil || !self.currentTimer!.isValid {
          Logger.debug("Timer invalid after activation - rescheduling")
          self.lastScheduledMinute = -1
          self.scheduleNextMinuteRefresh()
        } else {
          Logger.debug("Timer valid after activation")
        }
      }
    }
  }

  private func cleanup() {
    Logger.debug("EventData deinitializing")
    cancelCurrentTimer()

    if let observer = workspaceNotificationObserver {
      NSWorkspace.shared.notificationCenter.removeObserver(observer)
    }

    if let observer = appActivationObserver {
      NotificationCenter.default.removeObserver(observer)
    }
  }
}
