import Defaults
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private var hasRequestedPermission = false
    
    private init() {
        // Check for existing notification settings on init
        Task { await checkNotificationSettings() }
    }
    
    @MainActor
    private func checkNotificationSettings() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        if settings.authorizationStatus == .notDetermined,
           Defaults[.meetingNotificationTime] != nil {
            try? await requestAuthorization()
        }
    }
    
    @MainActor
    func requestAuthorization() async throws {
        guard !hasRequestedPermission else { return }
        hasRequestedPermission = true
        
        let options: UNAuthorizationOptions = [.alert]
        // Let errors propagate naturally
        try await UNUserNotificationCenter.current().requestAuthorization(options: options)
    }
    
    @MainActor
    func checkEventsForNotifications(_ events: [GoogleEvent]) async {
        do {
            guard let minutes = Defaults[.meetingNotificationTime],
                  minutes > 0 else {
                // Clear all pending notifications if disabled
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
            // We don't propagate the error since this is a background operation
            // and the user can still use the app without notifications
        }
    }
    
    private func findNextEventRequiringNotification(from events: [GoogleEvent], after date: Date) -> GoogleEvent? {
        events
            .filter { event in
                guard let startTime = event.startTime else { return false }
                let notificationTime = startTime.addingTimeInterval(-Double(Defaults[.meetingNotificationTime] ?? 0 * 60))
                return startTime > date && notificationTime > date
            }
            .min { $0.startTime ?? date > $1.startTime ?? date }
    }
    
    private func handleNotificationForNextEvent(_ event: GoogleEvent, minutes: Int) async throws {
        guard let startTime = event.startTime else { return }
        
        let notificationTime = startTime.addingTimeInterval(-Double(minutes * 60))
        
        // Check if we need to reschedule
        if await !shouldRescheduleNotification(for: event, at: notificationTime) {
            return
        }
        
        await clearAllNotifications()
        try await scheduleNotification(for: event, minutes: minutes)
    }
    
    private func shouldRescheduleNotification(for event: GoogleEvent, at expectedTime: Date) async -> Bool {
        let pendingRequests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        
        guard let existingRequest = pendingRequests.first(where: { $0.identifier == event.id }),
              let trigger = existingRequest.trigger as? UNCalendarNotificationTrigger,
              let scheduledDate = Calendar.current.date(from: trigger.dateComponents) else {
            return true
        }
        
        // If times match (within a minute), no need to reschedule
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
        
        // Calculate notification time
        let notificationTime = startTime.addingTimeInterval(-Double(minutes * 60))
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: notificationTime
        )
        
        // Create and schedule new notification
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = event.summary ?? "Untitled Event"
        content.body = "Starting in \(minutes) minutes"
        
        let request = UNNotificationRequest(
            identifier: event.id,
            content: content,
            trigger: trigger
        )
        
        // Let errors propagate naturally
        try await UNUserNotificationCenter.current().add(request)
        Logger.debug("Scheduled notification for next event: \(event.summary ?? "event") at \(notificationTime)")
    }
}
