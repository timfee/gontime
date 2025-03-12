//
//  EventFetcher.swift
//  gontime
//

import Combine
import Foundation
import SwiftUI

/// Manages calendar event data with automatic periodic refreshing.
/// Handles refreshing data at minute boundaries and when the system wakes from sleep.
@MainActor
final class EventData: ObservableObject {
    // MARK: - Published Properties
    
    /// The current list of calendar events
    @Published private(set) var events: [GoogleEvent] = []
    
    /// Timestamp of the last successful refresh
    @Published private(set) var lastRefreshDate: Date? = nil
    
    // MARK: - Private Properties
    private var refreshTimer: AnyCancellable?
    private let calendarService: CalendarDataService
    private var isActive = false
    private var workspaceNotificationObserver: NSObjectProtocol?
    private let notificationManager = NotificationManager.shared
    
    // MARK: - Constants
    
    private enum Constants {
        static let refreshInterval: TimeInterval = 60
    }
    
    // MARK: - Lifecycle
    
    /// Initializes the event data manager with the specified calendar service
    /// - Parameter calendarService: The service used to fetch calendar data
    init(calendarService: CalendarDataService) {
        Logger.debug("Initializing EventData")
        self.calendarService = calendarService
        setupWakeObserver()
    }
    
    /// Performs cleanup when the instance is deallocated
    deinit {
        // Note: We must use Task with @MainActor to safely access actor-isolated properties during deinit
        Task { @MainActor [weak self] in
            self?.cleanup()
        }
    }
    
    // MARK: - Public Methods
    
    /// Starts monitoring events with periodic refreshes at minute boundaries
    func start() {
        Logger.debug("Starting EventData")
        isActive = true
        Task {
            await refreshAndStartTimer()
        }
    }
    
    /// Stops event monitoring and cancels any pending refresh
    func stop() {
        Logger.debug("Stopping EventData")
        isActive = false
        cancelRefreshTimer()
    }
    
    /// Manually refreshes event data from the calendar service
    func refresh() async throws {
        Logger.debug("Starting refresh")
        do {
            let fetchedEvents = try await calendarService.fetchEvents()
            Logger.state("Fetched \(fetchedEvents.count) events")
            events = fetchedEvents
            lastRefreshDate = Date()
            await notificationManager.checkEventsForNotifications(events)
        } catch {
            // Error was already logged in service layer
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
        
        // Simple refresh every minute to keep event data current
        refreshTimer = Timer.publish(every: Constants.refreshInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isActive else { return }
                Task { @MainActor [weak self] in
                    try? await self?.refresh()
                }
            }
        
        // Initial refresh to ensure we're up to date
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
    
    /// Sets up an observer to detect when the system wakes from sleep
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
