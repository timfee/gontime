//
//  GoogleCalendarService.swift
//  gontime
//
//  Created by Tim Feeley on 2/20/25.
//

import Foundation
import Defaults
import GoogleSignIn

final class CalendarDataService {
    // MARK: - Properties
    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    private let baseURL: String
    private let eventFilter: EventFilterProtocol
    private let session: URLSession
    
    private lazy var components: URLComponents? = {
        var comps = URLComponents(string: baseURL)
        comps?.queryItems = buildQueryItems()
        return comps
    }()
    
    private lazy var request: URLRequest? = {
        guard let components = components, let url = components.url else { return nil }
        return URLRequest(url: url)
    }()
    
    // MARK: - Initialization
    init(
        baseURL: String = "https://www.googleapis.com/calendar/v3/calendars/primary/events",
        eventFilter: EventFilterProtocol = DefaultEventFilter(),
        session: URLSession? = nil
    ) {
        self.baseURL = baseURL
        self.eventFilter = eventFilter
        self.session = session ?? URLSession.shared
    }
    
    // MARK: - Public Methods
    func fetchEvents() async throws -> [GoogleEvent] {
        guard let req = request else {
            throw CalendarServiceError.request
        }
        
        do {
            let (data, response) = try await session.data(for: req)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw CalendarServiceError.network(NSError(domain: "HTTP", code: 0))
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                throw CalendarServiceError.network(
                    NSError(domain: "HTTP", code: httpResponse.statusCode)
                )
            }
            
            let decodedResponse = try JSONDecoder().decode(GoogleEventsResponse.self, from: data)
            return eventFilter.filter(decodedResponse.items)
        } catch let decodingError as DecodingError {
            throw CalendarServiceError.decode(decodingError)
        } catch let error {
            throw CalendarServiceError.network(error)
        }
    }
    
    // MARK: - Private Methods
    private func buildQueryItems() -> [URLQueryItem] {
        let now = Date()
        let calendar = Calendar.current
        let endOfDay = calendar.date(
            bySettingHour: 23, minute: 59, second: 59,
            of: calendar.startOfDay(for: now)
        ) ?? now
        
        return [
            URLQueryItem(name: "timeMin", value: Self.isoFormatter.string(from: now)),
            URLQueryItem(name: "timeMax", value: Self.isoFormatter.string(from: endOfDay)),
            URLQueryItem(name: "singleEvents", value: "true"),
            URLQueryItem(name: "orderBy", value: "startTime"),
            URLQueryItem(name: "eventTypes", value: "default"),
            URLQueryItem(name: "conferenceDataVersion", value: "1")
        ]
    }
}
