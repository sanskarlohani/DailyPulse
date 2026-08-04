import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var readingHistory: [Article] = []
    @Published var bookmarkCount: Int = 0
    
    // User preferences mapped directly to state
    @Published var isDarkModeEnabled = false {
        didSet { updatePreferences() }
    }
    @Published var isNotificationEnabled = true {
        didSet { updatePreferences() }
    }
    @Published var selectedLanguage = "English" {
        didSet { updatePreferences() }
    }
    
    let availableLanguages = ["English", "Spanish", "French", "German", "Japanese", "Chinese"]
    
    private let storageService: StorageServiceProtocol
    private let authViewModel: AuthViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(storageService: StorageServiceProtocol, authViewModel: AuthViewModel) {
        self.storageService = storageService
        self.authViewModel = authViewModel
        
        // Initialize preferences from logged in user
        if let user = authViewModel.currentUser {
            self.isDarkModeEnabled = user.preferences.isDarkModeEnabled
            self.isNotificationEnabled = user.preferences.isNotificationEnabled
            self.selectedLanguage = user.preferences.selectedLanguage
        }
    }
    
    func refreshStatsAndHistory() {
        readingHistory = storageService.fetchHistory()
        bookmarkCount = storageService.fetchBookmarks().count
    }
    
    func clearHistory() {
        storageService.clearHistory()
        refreshStatsAndHistory()
    }
    
    private func updatePreferences() {
        guard var prefs = authViewModel.currentUser?.preferences else { return }
        
        // Avoid infinite updates if they didn't change
        if prefs.isDarkModeEnabled != isDarkModeEnabled ||
           prefs.isNotificationEnabled != isNotificationEnabled ||
           prefs.selectedLanguage != selectedLanguage {
            
            prefs.isDarkModeEnabled = isDarkModeEnabled
            prefs.isNotificationEnabled = isNotificationEnabled
            prefs.selectedLanguage = selectedLanguage
            
            authViewModel.updatePreferences(prefs)
        }
    }
}
