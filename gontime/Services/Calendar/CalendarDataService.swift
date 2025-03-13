//
//  CalendarDataService.swift
//  gontime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@google.com
//

import Defaults
import Foundation
import GoogleSignIn

/// Manages calendar event data fetching and processing
final class CalendarDataService {

  // MARK: - Constants

  private enum Constants {
    static let defaultBaseURL = "https://www.googleapis.com/calendar/v3/calendars/primary/events"
  }

  // MARK: - Properties

  /// Formatter for ISO8601 date strings in API requests
  private static let isoFormatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    return formatter
  }()

  private let baseURL: String
  private let eventFilter: EventFilterProtocol

  // MARK: - Initialization

  init(
    baseURL: String = Constants.defaultBaseURL,
    eventFilter: EventFilterProtocol = DefaultEventFilter()
  ) {
    self.baseURL = baseURL
    self.eventFilter = eventFilter
  }

  // MARK: - Public Methods

  /// Fetches and filters calendar events for the current day
  /// - Returns: Array of filtered GoogleEvent objects
  /// - Throws: AppError for network, decoding, or authorization failures
  @MainActor

  func fetchEvents() async throws -> [GoogleEvent] {
    Logger.debug("Fetching events")

    let url = try buildEventsURL()
    Logger.debug("Fetching from URL: \(url.absoluteString)")

    let session = try await AuthorizationTokenService.createSession()
    let request = URLRequest(url: url)

    do {
      Logger.debug("Making network request")
      let (data, response) = try await session.data(for: request)

      guard let httpResponse = response as? HTTPURLResponse else {
        throw AppError.network(URLError(.badServerResponse))
      }
      Logger.debug("Received response with status code: \(httpResponse.statusCode)")

      guard (200...299).contains(httpResponse.statusCode) else {
        throw AppError.network(URLError(.badServerResponse))
      }

      let decoder = JSONDecoder()
      let decodedResponse = try decoder.decode(GoogleEventsResponse.self, from: data)
      let filteredEvents = eventFilter.filter(decodedResponse.items)

      Logger.state(
        "Fetched \(decodedResponse.items.count) events, filtered to \(filteredEvents.count)")
      return filteredEvents

    } catch let error as DecodingError {
      throw AppError.decode(error)
    } catch let error as AppError {
      throw error
    } catch {
      throw AppError.network(error)
    }
  }

  // MARK: - Private Helpers

  private func buildEventsURL() throws -> URL {
    let now = Date()

    // Only get events that end after 5 minutes ago
    let startTime = now.addingTimeInterval(-300)  // 5 minutes ago
    let endOfDay =
      Calendar.current.date(
        bySettingHour: 7,
        minute: 0,
        second: 0,
        of: now.addingTimeInterval(24 * 60 * 60)
      ) ?? now

    Logger.debug("Fetching events between \(startTime) and \(endOfDay)")

    var components = URLComponents(string: baseURL)
    components?.queryItems = [
      URLQueryItem(name: "timeMin", value: Self.isoFormatter.string(from: startTime)),
      URLQueryItem(name: "timeMax", value: Self.isoFormatter.string(from: endOfDay)),
      URLQueryItem(name: "singleEvents", value: "true"),
      URLQueryItem(name: "orderBy", value: "startTime"),
      URLQueryItem(name: "eventTypes", value: "default"),
      URLQueryItem(name: "conferenceDataVersion", value: "1"),
    ]

    guard let url = components?.url else {
      throw AppError.request(URLError(.badURL))
    }

    return url
  }
}
