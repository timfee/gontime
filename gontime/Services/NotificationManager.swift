//
//  NotificationManager.swift
//  gOnTime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@ (Tim Feeley)
//

import Defaults
import UserNotifications

// Your imports remain the same

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
        do {
            guard let minutes = Defaults[.meetingNotificationTime],
                  minutes > 0
            else {
                await clearAllNotifications()
                return
            }
            
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            guard settings.authorizationStatus == .authorized else { return }
            
            let now = Date()
            guard let nextEvent = findNextEventRequiringNotification(from: events, after: now) else {
                if await !pendingNotificationsExist() {
                    await clearAllNotifications()
                }
                return
            }
            
            try await handleNotificationForNextEvent(nextEvent, minutes: minutes)
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
    
    private func findNextEventRequiringNotification(from events: [GoogleEvent], after date: Date)
    -> GoogleEvent?
    {
        events
            .filter { event in
                guard let startTime = event.startTime else { return false }
                let notificationTime = startTime.addingTimeInterval(
                    -Double(Defaults[.meetingNotificationTime] ?? 0 * 60))
                return startTime > date && notificationTime > date
            }
            .min { $0.startTime ?? date > $1.startTime ?? date }
    }
    
    private func handleNotificationForNextEvent(_ event: GoogleEvent, minutes: Int) async throws {
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

// End of file
