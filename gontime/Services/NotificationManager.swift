import Defaults
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private var lastNotifiedEventIds: Set<String> = []
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
            // If we have notifications enabled but no permission, request it
            await requestAuthorization()
        }
    }
    
    @MainActor
    func requestAuthorization() async {
        guard !hasRequestedPermission else { return }
        hasRequestedPermission = true
        
        do {
            let options: UNAuthorizationOptions = [.alert]
            try await UNUserNotificationCenter.current().requestAuthorization(options: options)
        } catch {
            print("Error requesting notification authorization: \(error)")
        }
    }
    
    @MainActor
    func checkEventsForNotifications(_ events: [GoogleEvent]) async {
        guard let minutes = Defaults[.meetingNotificationTime],
              minutes > 0 else {
            lastNotifiedEventIds.removeAll()
            return
        }
        
        // Check authorization status when notifications are enabled
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        guard settings.authorizationStatus == .authorized else {
            // Don't proceed if not authorized
            return
        }
        
        var currentEventIds = Set<String>()
        let now = Date()
        let calendar = Calendar.current
        
        for event in events {
            guard let startTime = event.startTime,
                  startTime > now,
                  !lastNotifiedEventIds.contains(event.id) else { continue }
            
            // Add null check for components.minute
            let components = calendar.dateComponents(
                [.minute],
                from: now,
                to: startTime
            )
            
            guard let minutesUntilStart = components.minute,
                  minutesUntilStart == minutes else { continue }
            
            currentEventIds.insert(event.id)
            let content = UNMutableNotificationContent()
            content.title = event.summary ?? "Untitled Event"
            content.body = "Starting in \(minutes) minutes"
            
            let request = UNNotificationRequest(
                identifier: event.id,
                content: content,
                trigger: nil  // Deliver immediately
            )
            
            do {
                try await UNUserNotificationCenter.current().add(request)
            } catch {
                print("Error sending notification: \(error)")
            }
        }
        
        // Update our tracking set with current notifications
        lastNotifiedEventIds = currentEventIds
    }
}
