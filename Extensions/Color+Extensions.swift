import SwiftUI

extension Color {
    // Custom theme names matching assets
    static let themePrimary = Color("ThemePrimary")
    static let themeSecondary = Color("ThemeSecondary")
    static let themeBackground = Color("ThemeBackground")
    static let themeCardBg = Color("ThemeCardBg")
    static let themeText = Color("ThemeText")
    static let themeSecondaryText = Color("ThemeSecondaryText")
    static let themeBorder = Color("ThemeBorder")
    
    // Core brand constants
    static let brandBlue = Color(red: 0.08, green: 0.49, blue: 0.98)
    static let brandIndigo = Color(red: 0.34, green: 0.34, blue: 0.84)
    static let brandOrange = Color(red: 0.95, green: 0.60, blue: 0.18)
    
    static let brandGradient = LinearGradient(
        colors: [Color.brandBlue, Color.brandIndigo],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
