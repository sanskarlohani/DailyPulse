import Foundation

struct User: Codable, Identifiable, Hashable {
    let id: String
    var email: String
    var name: String
    var avatarURL: String?
    var joinedDate: Date
    var preferences: UserPreferences
    
    struct UserPreferences: Codable, Hashable {
        var isDarkModeEnabled: Bool = false
        var isNotificationEnabled: Bool = true
        var selectedLanguage: String = "English"
        var selectedCategories: [String] = ["Technology", "Business", "Sports"]
    }
    
    // Sample guest user definition
    static var guestUser: User {
        User(
            id: "guest_id",
            email: "guest@dailypulse.com",
            name: "Guest Reader",
            joinedDate: Date(),
            preferences: UserPreferences()
        )
    }
}
