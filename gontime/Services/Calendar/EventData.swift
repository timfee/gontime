//
//  EventFetcher.swift
//  gontime
//

import Combine
import Foundation

final class EventData: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var events: [GoogleEvent] = []
    @Published private(set) var error: String? = nil
    
    // MARK: - Private Properties
    private var timerPublisher: AnyCancellable?
    private let calendarService: CalendarDataService
    
    init(calendarService: CalendarDataService) {
        self.calendarService = calendarService
    }
    
    func start() {
        Task { await refresh() }
        startTimer()
    }
    
    func stop() {
        stopTimer()
        events = []
    }
    
    func refresh() async {
        do {
            events = try await calendarService.fetchEvents()
            error = nil
        } catch let catchError {
            error = catchError.localizedDescription
            events = []
        }
    }
    
    // MARK: - Private Methods
    private func startTimer() {
        stopTimer() // Prevent duplicate timers
        timerPublisher = Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { await self?.refresh() }
            }
    }
    
    private func stopTimer() {
        timerPublisher?.cancel()
        timerPublisher = nil
    }
}

// End of file
