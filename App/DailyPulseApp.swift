import SwiftUI
import SwiftData
import FirebaseCore

@main
struct DailyPulseApp: App {
    @StateObject private var authViewModel: AuthViewModel
    @State private var isSplashActive = false
    
    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        _authViewModel = StateObject(wrappedValue: AuthViewModel())
    }
    
    var body: some Scene {
        WindowGroup {
            if !isSplashActive {
                LaunchScreen(isActive: $isSplashActive)
            } else {
                AuthView()
                    .environmentObject(authViewModel)
                    .preferredColorScheme(preferredScheme)
            }
        }
        .modelContainer(for: Article.self)
    }
    
    // Dynamic styling color scheme based on user preferences
    private var preferredScheme: ColorScheme? {
        guard let user = authViewModel.currentUser else { return nil }
        return user.preferences.isDarkModeEnabled ? .dark : .light
    }
}
