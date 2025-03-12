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

@MainActor
final class EventData: ObservableObject {

  // MARK: - Constants

  private enum Constants {
    static let refreshInterval: TimeInterval = 60
  }

  // MARK: - Published Properties

  @Published private(set) var events: [GoogleEvent] = []
  @Published private(set) var lastRefreshDate: Date? = nil

  // MARK: - Private Properties

  private var refreshTimer: AnyCancellable?
  private let calendarService: CalendarDataService
  private var isActive = false
  private var workspaceNotificationObserver: NSObjectProtocol?
  private let notificationManager = NotificationManager.shared

  // MARK: - Lifecycle

  init(calendarService: CalendarDataService) {
    Logger.debug("Initializing EventData")
    self.calendarService = calendarService
    setupWakeObserver()
  }

  deinit {
    Task { @MainActor [weak self] in
      self?.cleanup()
    }
  }

  // MARK: - Public Methods

  /// Starts event monitoring and refresh timer

  func start() {
    Logger.debug("Starting EventData")
    isActive = true
    Task {
      await refreshAndStartTimer()
    }

  }

  /// Stops event monitoring and cleanup

  func stop() {
    Logger.debug("Stopping EventData")
    isActive = false
    cancelRefreshTimer()
  }

  /// Manually refreshes events
  /// - Throws: AppError if refresh fails

  func refresh() async throws {
    Logger.debug("Starting refresh")
    do {
      let fetchedEvents = try await calendarService.fetchEvents()
      Logger.state("Fetched \(fetchedEvents.count) events")
      events = fetchedEvents
      lastRefreshDate = Date()
      await notificationManager.checkEventsForNotifications(events)
    } catch {
      self.events = []
      throw error as? AppError ?? .calendar(error)
    }

  }

  // MARK: - Private Methods

  private func startRefreshTimer() {
    Logger.debug("Starting refresh timer")
    cancelRefreshTimer()
    guard isActive else {
      Logger.debug("Not starting refresh timer - EventData inactive")
      return
    }

    refreshTimer = Timer.publish(every: Constants.refreshInterval, on: .main, in: .common)
      .autoconnect()
      .sink { [weak self] _ in
        guard let self = self, self.isActive else { return }
        Task { @MainActor [weak self] in
          try? await self?.refresh()
        }
      }

    Task { @MainActor [weak self] in
      try? await self?.refresh()
    }
  }

  private func refreshAndStartTimer() async {
    try? await refresh()
    startRefreshTimer()
  }

  private func cleanup() {
    Logger.debug("EventData deinitializing")
    cancelRefreshTimer()
    if let observer = workspaceNotificationObserver {
      NSWorkspace.shared.notificationCenter.removeObserver(observer)
    }
  }

  private func cancelRefreshTimer() {
    refreshTimer?.cancel()
    refreshTimer = nil
  }

  private func setupWakeObserver() {
    Logger.debug("Setting up system wake observer")
    workspaceNotificationObserver = NSWorkspace.shared.notificationCenter.addObserver(
      forName: NSWorkspace.didWakeNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      Task { @MainActor [weak self] in
        guard let self = self, self.isActive else { return }
        Logger.state("System woke from sleep - refreshing data")
        await self.refreshAndStartTimer()
      }
    }
  }
}
