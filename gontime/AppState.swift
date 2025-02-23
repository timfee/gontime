import Combine
import Defaults
import GoogleSignIn
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    // MARK: - Published State
    @Published private(set) var authState: AuthState = .signedOut {
        didSet { handleAuthStateChange() }
    }
    @Published private(set) var menuBarTitle: String = AppConstants.MenuBar.defaultTitle
    @Published private(set) var currentError: AppError? = nil
    
    // MARK: - Private Properties
    private let eventFetcher: EventData
    private let menuDecorator: MenuBarDecorator
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Properties
    var events: [GoogleEvent] { eventFetcher.events }
    
    // MARK: - Initialization
    init(
        calendarService: CalendarDataService = CalendarDataService(),
        eventFetcher: EventData? = nil,
        menuDecorator: MenuBarDecorator = MenuBarDecorator()
    ) {
        self.eventFetcher = eventFetcher ?? EventData(calendarService: calendarService)
        self.menuDecorator = menuDecorator
        
        if let user = GIDSignIn.sharedInstance.currentUser {
            authState = .signedIn(user)
        } else if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
                guard let self = self else { return }
                if let user = user {
                    self.authState = .signedIn(user)
                } else if let error = error {
                    self.handleError(error)
                }
            }
        }
        setupObservers()
    }
    
    // MARK: - Public Methods
    func clearError() {
        currentError = nil
    }
    
    func signIn() {
        AuthenticationService().signIn { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success(let user):
                    self.authState = .signedIn(user)
                    self.clearError()
                case .failure(let error):
                    self.handleError(AppError.auth(error))
            }
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        authState = .signedOut
        clearError()
    }
    
    // MARK: - Private Methods
    private func handleError(_ error: AppError) {
        currentError = error
    }
    
    private func handleError(_ error: Error) {
        if let appError = error as? AppError {
            currentError = appError
        } else {
            currentError = .general(error.localizedDescription)
        }
    }
    
    private func handleAuthStateChange() {
        switch authState {
            case .signedIn:
                eventFetcher.start()
            case .signedOut:
                eventFetcher.stop()
                menuBarTitle = AppConstants.MenuBar.allClearTitle
        }
    }
    
    private func setupObservers() {
        // Event and error changes
        eventFetcher.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                if let errorMessage = self.eventFetcher.error {
                    self.handleError(AppError.calendar(NSError(
                        domain: "Calendar",
                        code: 0,
                        userInfo: [NSLocalizedDescriptionKey: errorMessage]
                    )))
                }
                self.menuBarTitle = self.menuDecorator.decorateTitle(
                    error: self.eventFetcher.error,
                    events: self.eventFetcher.events
                )
            }
            .store(in: &cancellables)
        
        // Settings changes
        Defaults.publisher(keys: [
            .showEventTitleInMenuBar,
            .truncatedEventTitleLength,
            .simplifyEventTitles
        ])
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
            guard let self = self else { return }
            self.menuBarTitle = self.menuDecorator.decorateTitle(
                error: self.eventFetcher.error,
                events: self.eventFetcher.events
            )
        }
        .store(in: &cancellables)
    }
    
    // MARK: - Auth State
    enum AuthState {
        case signedIn(GIDGoogleUser)
        case signedOut
    }
}
