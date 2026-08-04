import Foundation

protocol AuthServiceProtocol {
    var currentUser: User? { get }
    func login(email: String, password: String) async throws -> User
    func register(name: String, email: String, password: String) async throws -> User
    func forgotPassword(email: String) async throws
    func loginAsGuest() async -> User
    func logout()
    func updatePreferences(_ preferences: User.UserPreferences)
}

final class AuthService: AuthServiceProtocol, ObservableObject {
    @Published private(set) var currentUser: User?
    
    private let userDefaultsKey = "current_session_user"
    
    init() {
        loadSession()
    }
    
    private func loadSession() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return }
        do {
            currentUser = try JSONDecoder().decode(User.self, from: data)
        } catch {
            print("Failed to decode session user: \(error)")
        }
    }
    
    private func saveSession(_ user: User) {
        do {
            let data = try JSONEncoder().encode(user)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
            currentUser = user
        } catch {
            print("Failed to save session user: \(error)")
        }
    }
    
    func login(email: String, password: String) async throws -> User {
        try await Task.sleep(nanoseconds: 1_200_000_000) // Simulate request
        
        guard !email.isEmpty, !password.isEmpty else {
            throw NSError(domain: "Auth", code: 400, userInfo: [NSLocalizedDescriptionKey: "Email and password cannot be empty."])
        }
        
        let name = email.components(separatedBy: "@").first?.capitalized ?? "Reader"
        let loggedInUser = User(
            id: UUID().uuidString,
            email: email,
            name: name,
            joinedDate: Date(),
            preferences: User.UserPreferences()
        )
        
        saveSession(loggedInUser)
        return loggedInUser
    }
    
    func register(name: String, email: String, password: String) async throws -> User {
        try await Task.sleep(nanoseconds: 1_500_000_000)
        
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            throw NSError(domain: "Auth", code: 400, userInfo: [NSLocalizedDescriptionKey: "All fields are required."])
        }
        
        let newUser = User(
            id: UUID().uuidString,
            email: email,
            name: name,
            joinedDate: Date(),
            preferences: User.UserPreferences()
        )
        
        saveSession(newUser)
        return newUser
    }
    
    func forgotPassword(email: String) async throws {
        try await Task.sleep(nanoseconds: 800_000_000)
        guard !email.isEmpty else {
            throw NSError(domain: "Auth", code: 400, userInfo: [NSLocalizedDescriptionKey: "Email is required."])
        }
        // Simulated password reset trigger
    }
    
    func loginAsGuest() async -> User {
        let guest = User.guestUser
        saveSession(guest)
        return guest
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        currentUser = nil
    }
    
    func updatePreferences(_ preferences: User.UserPreferences) {
        guard var user = currentUser else { return }
        user.preferences = preferences
        saveSession(user)
    }
}
