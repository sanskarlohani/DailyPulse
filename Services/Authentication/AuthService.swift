import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

@MainActor
protocol AuthServiceProtocol: AnyObject {
    var currentUser: User? { get }
    func login(email: String, password: String) async throws -> User
    func register(name: String, email: String, password: String) async throws -> User
    func forgotPassword(email: String) async throws
    func loginAsGuest() async -> User
    func logout()
    func updatePreferences(_ preferences: User.UserPreferences)
}

@MainActor
final class AuthService: AuthServiceProtocol, ObservableObject {
    @Published private(set) var currentUser: User?
    
    private let userDefaultsKey = "current_session_user"
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    private lazy var db = Firestore.firestore()
    
    init() {
        loadSession()
        setupAuthStateListener()
    }
    
    deinit {
        // AuthState listener removal on deinit
    }
    
    private func setupAuthStateListener() {
        guard FirebaseApp.app() != nil else { return }
        
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                if let fbUser = firebaseUser {
                    if let remoteUser = await self.fetchUserFromFirestore(userId: fbUser.uid) {
                        self.saveSession(remoteUser)
                        self.savePreferences(remoteUser.preferences, for: remoteUser.id)
                    } else {
                        let user = self.mapFirebaseUser(fbUser)
                        self.saveSession(user)
                    }
                } else if self.currentUser != nil && Auth.auth().currentUser == nil {
                    self.currentUser = nil
                    UserDefaults.standard.removeObject(forKey: self.userDefaultsKey)
                }
            }
        }
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
    
    private func preferencesKey(for userId: String) -> String {
        "user_preferences_\(userId)"
    }
    
    private func loadPreferences(for userId: String) -> User.UserPreferences {
        guard let data = UserDefaults.standard.data(forKey: preferencesKey(for: userId)),
              let preferences = try? JSONDecoder().decode(User.UserPreferences.self, from: data) else {
            return User.UserPreferences()
        }
        return preferences
    }
    
    private func savePreferences(_ preferences: User.UserPreferences, for userId: String) {
        if let data = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(data, forKey: preferencesKey(for: userId))
        }
    }
    
    private func mapFirebaseUser(_ fbUser: FirebaseAuth.User, fallbackName: String? = nil) -> User {
        let email = fbUser.email ?? (fbUser.isAnonymous ? "guest@dailypulse.com" : "")
        let defaultName = fbUser.isAnonymous ? "Guest Reader" : (email.components(separatedBy: "@").first?.capitalized ?? "Reader")
        let name = fbUser.displayName ?? fallbackName ?? defaultName
        let joinedDate = fbUser.metadata.creationDate ?? Date()
        let preferences = loadPreferences(for: fbUser.uid)
        
        return User(
            id: fbUser.uid,
            email: email,
            name: name,
            avatarURL: fbUser.photoURL?.absoluteString,
            joinedDate: joinedDate,
            preferences: preferences
        )
    }
    
    // MARK: - Firestore Sync
    
    func syncUserToFirestore(_ user: User) async {
        guard FirebaseApp.app() != nil, Auth.auth().currentUser != nil else { return }
        do {
            try db.collection("users").document(user.id).setData(from: user, merge: true)
            print("Successfully persisted user data to Firestore: \(user.id)")
        } catch {
            print("Failed to sync user to Firestore: \(error.localizedDescription)")
        }
    }
    
    func fetchUserFromFirestore(userId: String) async -> User? {
        guard FirebaseApp.app() != nil, Auth.auth().currentUser != nil else { return nil }
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            if document.exists {
                let user = try document.data(as: User.self)
                return user
            }
        } catch {
            print("Failed to fetch user from Firestore: \(error.localizedDescription)")
        }
        return nil
    }
    
    // MARK: - Authentication Operations
    
    func login(email: String, password: String) async throws -> User {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty, !password.isEmpty else {
            throw NSError(domain: "Auth", code: 400, userInfo: [NSLocalizedDescriptionKey: "Email and password cannot be empty."])
        }
        
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        
        if let firestoreUser = await fetchUserFromFirestore(userId: result.user.uid) {
            saveSession(firestoreUser)
            savePreferences(firestoreUser.preferences, for: firestoreUser.id)
            return firestoreUser
        }
        
        let loggedInUser = mapFirebaseUser(result.user)
        saveSession(loggedInUser)
        await syncUserToFirestore(loggedInUser)
        return loggedInUser
    }
    
    func register(name: String, email: String, password: String) async throws -> User {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.isEmpty else {
            throw NSError(domain: "Auth", code: 400, userInfo: [NSLocalizedDescriptionKey: "All fields are required."])
        }
        
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        
        let changeRequest = result.user.createProfileChangeRequest()
        changeRequest.displayName = name
        try await changeRequest.commitChanges()
        
        var newUser = mapFirebaseUser(result.user, fallbackName: name)
        newUser.name = name
        saveSession(newUser)
        await syncUserToFirestore(newUser)
        return newUser
    }
    
    func forgotPassword(email: String) async throws {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw NSError(domain: "Auth", code: 400, userInfo: [NSLocalizedDescriptionKey: "Email is required."])
        }
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func loginAsGuest() async -> User {
        do {
            let result = try await Auth.auth().signInAnonymously()
            if let firestoreGuest = await fetchUserFromFirestore(userId: result.user.uid) {
                saveSession(firestoreGuest)
                return firestoreGuest
            }
            let guest = mapFirebaseUser(result.user, fallbackName: "Guest Reader")
            saveSession(guest)
            await syncUserToFirestore(guest)
            return guest
        } catch {
            print("Firebase anonymous auth failed: \(error). Using local guest fallback.")
            let guest = User.guestUser
            saveSession(guest)
            return guest
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Failed to sign out from Firebase: \(error)")
        }
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        currentUser = nil
    }
    
    func updatePreferences(_ preferences: User.UserPreferences) {
        guard var user = currentUser else { return }
        user.preferences = preferences
        savePreferences(preferences, for: user.id)
        saveSession(user)
        
        Task { [weak self, user] in
            await self?.syncUserToFirestore(user)
        }
    }
}
