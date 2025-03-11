//
//  EventFetcher.swift
//  gontime
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class EventData: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var events: [GoogleEvent] = []
    @Published private(set) var error: String? = nil
    
    // MARK: - Private Properties
    private var timerTask: Task<Void, Never>?
    private let calendarService: CalendarDataService
    private var isActive = false
    private var workspaceNotificationObserver: NSObjectProtocol?
    private let notificationManager = NotificationManager.shared
    
    init(calendarService: CalendarDataService) {
        self.calendarService = calendarService
        setupWakeObserver()
    }
    
    func start() {
        isActive = true
        Task {
            await refresh()
            startTimer()
        }
    }
    
    func stop() {
        isActive = false
        stopTimer()
    }
    
    func refresh() async {
        do {
            events = try await calendarService.fetchEvents()
            error = nil
        } catch {
            self.error = error.localizedDescription
            events = []
        }
    }
    
    // MARK: - Private Methods
    private func startTimer() {
        stopTimer()
        guard isActive else { return }
        
        timerTask = Task { @MainActor [weak self] in
            repeat {
                guard let self else { break }
                
                let calendar = Calendar.current
                let second = calendar.component(.second, from: Date())
                
                if second == 59 {
                    await self.refresh()
                    await self.notificationManager.checkEventsForNotifications(self.events)
                }
                
                // Check if we should continue before sleeping
                if !self.isActive || Task.isCancelled { break }
                
                try? await Task.sleep(for: .seconds(1))
            } while true
        }
    }
    
    private func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
    }
    
    private func setupWakeObserver() {
        workspaceNotificationObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if self.isActive {
                    await self.refresh()
                    self.startTimer()
                }
            }
        }
    }
    
    deinit {
        timerTask?.cancel()
        timerTask = nil
        if let observer = workspaceNotificationObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
        }
    }
}
