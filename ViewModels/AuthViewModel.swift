import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var name = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showForgotPasswordSuccess = false
    
    @Published var currentUser: User?
    
    private let authService: AuthService
    
    var isAuthenticated: Bool {
        currentUser != nil
    }
    
    init(authService: AuthService = AuthService()) {
        self.authService = authService
        self.currentUser = authService.currentUser
    }
    
    func login() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try await authService.login(email: email, password: password)
            self.currentUser = user
            clearInputFields()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func register() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try await authService.register(name: name, email: email, password: password)
            self.currentUser = user
            clearInputFields()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func forgotPassword() async {
        isLoading = true
        errorMessage = nil
        showForgotPasswordSuccess = false
        
        do {
            try await authService.forgotPassword(email: email)
            showForgotPasswordSuccess = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func loginAsGuest() async {
        isLoading = true
        errorMessage = nil
        
        let guest = await authService.loginAsGuest()
        self.currentUser = guest
        clearInputFields()
        
        isLoading = false
    }
    
    func logout() {
        authService.logout()
        self.currentUser = nil
    }
    
    func updatePreferences(_ preferences: User.UserPreferences) {
        authService.updatePreferences(preferences)
        self.currentUser = authService.currentUser
    }
    
    private func clearInputFields() {
        email = ""
        password = ""
        name = ""
    }
}
