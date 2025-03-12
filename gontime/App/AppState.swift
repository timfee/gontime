//
//  App/AppState.swift
//  gOnTime
//
//  Copyright 2025 Google LLC
//
//  Author: timfee@ (Tim Feeley)
//

import Combine
import Defaults
import GoogleSignIn
import SwiftUI

@MainActor
final class AppState: ObservableObject {
  private enum Constants {
    static let defaultTitle = "Calendar"
    static let signedOutTitle = "All clear"
  }
  @Published private(set) var authState: AuthState = .signedOut {
    didSet { Task { await handleAuthStateChange() } }
  }
  @Published private(set) var menuBarTitle: String = Constants.defaultTitle
  @Published private(set) var currentError: AppError? = nil
  @Published private(set) var events: [GoogleEvent] = []
  private let eventFetcher: EventData
  private let titleGenerator: MenuBarTitleGenerator
  private let authenticationService: AuthenticationService
  private var cancellables = Set<AnyCancellable>()
  init(
    calendarService: CalendarDataService = CalendarDataService(),
    eventFetcher: EventData? = nil,
    titleGenerator: MenuBarTitleGenerator = MenuBarDecorator(),
    authenticationService: AuthenticationService = AuthenticationService()
  ) {
    Logger.debug("Initializing AppState")
    self.eventFetcher = eventFetcher ?? EventData(calendarService: calendarService)
    self.titleGenerator = titleGenerator
    self.authenticationService = authenticationService
    setupInitialAuthState()
    setupObservers()
  }
  func clearError() {
    currentError = nil
  }
  func signIn() async {
    do {
      let user = try await authenticationService.signIn()
      self.authState = .signedIn(user)
      self.currentError = nil
    } catch {
      self.authState = .signedOut
      self.currentError = error as? AppError ?? .auth(error)
    }
  }
  func signOut() {
    GIDSignIn.sharedInstance.signOut()
    authState = .signedOut
    currentError = nil
    events = []
  }
  func refreshEvents() {
    if case .signedIn = authState {
      Task {
        do {
          eventFetcher.start()
          try await eventFetcher.refresh()
          self.currentError = nil
        } catch {
          self.currentError = error as? AppError ?? .calendar(error)
        }
      }
    } else {
      eventFetcher.stop()
    }
  }
  private func setupInitialAuthState() {
    if let user = GIDSignIn.sharedInstance.currentUser {
      Logger.state("Found existing signed-in user")
      self.authState = .signedIn(user)
      return
    }
    guard GIDSignIn.sharedInstance.hasPreviousSignIn() else { return }
    Logger.state("Attempting to restore previous sign-in")
    Task {
      do {
        let user = try await GIDSignIn.sharedInstance.restorePreviousSignInAsync()
        Logger.state("Successfully restored previous sign-in")
        self.authState = .signedIn(user)
      } catch {
        self.authState = .signedOut
        self.currentError = error as? AppError ?? .auth(error)
      }
    }
  }
  private func handleError(_ error: Error) {
    self.currentError = error as? AppError ?? .general(error)
  }
  private func handleAuthStateChange() async {
    Logger.state("Auth state changed to: \(authState)")
    switch authState {
    case .signedIn:
      Logger.debug("Starting event fetcher")
      eventFetcher.start()
    case .signedOut:
      Logger.debug("Stopping event fetcher")
      eventFetcher.stop()
      menuBarTitle = Constants.signedOutTitle
    }
  }
  private func setupObservers() {
    Logger.debug("Setting up observers")
    eventFetcher.$events
      .receive(on: DispatchQueue.main)
      .sink { [weak self] events in
        guard let self = self else { return }
        self.events = events
        self.updateMenuBarTitle(events: events, error: self.currentError?.localizedDescription)
      }
      .store(in: &cancellables)
    Defaults.publisher(keys: [
      .showEventTitleInMenuBar,
      .truncatedEventTitleLength,
      .simplifyEventTitles,
    ])
    .receive(on: DispatchQueue.main)
    .sink { [weak self] _ in
      guard let self = self else { return }
      self.updateMenuBarTitle(events: self.events, error: self.currentError?.localizedDescription)
    }
    .store(in: &cancellables)
  }
  private func updateMenuBarTitle(events: [GoogleEvent], error: String?) {
    menuBarTitle = titleGenerator.generateTitle(
      error: error,
      events: events
    )
  }
  enum AuthState {
    case signedIn(GIDGoogleUser)
    case signedOut
  }
}
