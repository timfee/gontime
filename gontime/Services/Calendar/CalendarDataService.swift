//
//  Services/Calendar/CalendarDataService.swift
//  gOnTime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@ (Tim Feeley)
//

import Defaults
import Foundation
import GoogleSignIn

final class CalendarDataService {
  private enum Constants {
    static let defaultBaseURL = "https://www.googleapis.com/calendar/v3/calendars/primary/events"
  }
  private static let isoFormatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    return formatter
  }()
  private let baseURL: String
  private let eventFilter: EventFilterProtocol
  init(
    baseURL: String = Constants.defaultBaseURL,
    eventFilter: EventFilterProtocol = DefaultEventFilter()
  ) {
    self.baseURL = baseURL
    self.eventFilter = eventFilter
  }
  @MainActor
  func fetchEvents() async throws -> [GoogleEvent] {
    Logger.debug("Fetching events")
    guard let url = createRequestURL() else {
      throw AppError.request(URLError(.badURL))
    }
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
      Logger.debug("")
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
  private func createRequestURL() -> URL? {
    var components = URLComponents(string: baseURL)
    components?.queryItems = buildQueryItems()
    return components?.url
  }
  private func buildQueryItems() -> [URLQueryItem] {
    let now = Date()
    let calendar = Calendar.current
    let endOfDay =
      calendar.date(
        bySettingHour: 23,
        minute: 59,
        second: 59,
        of: calendar.startOfDay(for: now)
      ) ?? now
    return [
      URLQueryItem(name: "timeMin", value: Self.isoFormatter.string(from: now)),
      URLQueryItem(name: "timeMax", value: Self.isoFormatter.string(from: endOfDay)),
      URLQueryItem(name: "singleEvents", value: "true"),
      URLQueryItem(name: "orderBy", value: "startTime"),
      URLQueryItem(name: "eventTypes", value: "default"),
      URLQueryItem(name: "conferenceDataVersion", value: "1"),
    ]
  }
}
