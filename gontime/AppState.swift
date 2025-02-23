import Combine
import SwiftUI
import GoogleSignIn

@MainActor
final class AppState: ObservableObject {
    // MARK: - Published State
    @Published private(set) var currentError: String? = nil
    @Published private(set) var authState: AuthState = .signedOut
    @Published private(set) var events: [GoogleEvent] = []
    
    // MARK: - Private Properties
    private var timerPublisher: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    private let calendarService = GoogleCalendarService()
    
    // MARK: - Initialization
    init() {
        // Check for current user first
        if let user = GIDSignIn.sharedInstance.currentUser {
            authState = .signedIn(user)
            startFetchingEvents()
        }
        
        // Try to restore previous sign-in
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
            guard let self = self else { return }
            if let user = user {
                self.authState = .signedIn(user)
                self.startFetchingEvents()
            } else if let error = error {
                self.showError(error)
            }
        }
    }
    
    // MARK: - Public Methods
    func signIn() {
        GoogleSignInAuthenticator().signIn { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success(let user):
                    self.authState = .signedIn(user)
                    self.startFetchingEvents()
                case .failure(let error):
                    self.showError(error)
            }
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        authState = .signedOut
        stopFetchingEvents()
    }
    
    func showError(_ error: Error) {
        currentError = error.localizedDescription
    }
    
    func dismissError() {
        currentError = nil
    }
    
    // MARK: - Private Methods
    private func startFetchingEvents() {
        Task { await fetchEvents() }
        startTimer()
    }
    
    private func stopFetchingEvents() {
        stopTimer()
        events = []
    }
    
    private func fetchEvents() async {
        guard case let .signedIn(user) = authState else { return }
        
        do {
            events = try await calendarService.fetchEvents(accessToken: user.accessToken.tokenString)
        } catch {
            showError(error)
            events = []
        }
    }
    
    private func startTimer() {
        stopTimer()
        timerPublisher = Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in Task { await self?.fetchEvents() } }
    }
    
    private func stopTimer() {
        timerPublisher?.cancel()
        timerPublisher = nil
    }
    
    // MARK: - Auth State
    enum AuthState {
        case signedIn(GIDGoogleUser)
        case signedOut
    }
}

// End of file. No additional code.
