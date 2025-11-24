//
//  ThemeManager.swift
//  LifeHub
//
//  Manages app themes, color schemes, and appearance
//

import SwiftUI
import Combine

// Theme definitions
struct AppTheme: Identifiable, Codable {
    let id: String
    let name: String
    let accentColorHex: String
    let gradientStartHex: String
    let gradientEndHex: String
    
    var accentColor: Color {
        Color(hex: accentColorHex)
    }
    
    var gradientStart: Color {
        Color(hex: gradientStartHex)
    }
    
    var gradientEnd: Color {
        Color(hex: gradientEndHex)
    }
    
    var gradient: LinearGradient {
        LinearGradient(
            colors: [gradientStart, gradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme
    @Published var colorScheme: ColorScheme?
    @Published var isDarkMode: Bool {
        didSet {
            colorScheme = isDarkMode ? .dark : .light
            savePreferences()
        }
    }
    
    // Predefined themes
    let themes: [AppTheme] = [
        AppTheme(id: "ocean", name: "Ocean Wave", accentColorHex: "00B4D8", gradientStartHex: "0077B6", gradientEndHex: "00B4D8"),
        AppTheme(id: "sunset", name: "Sunset Glow", accentColorHex: "FF6B35", gradientStartHex: "F77F00", gradientEndHex: "FF6B35"),
        AppTheme(id: "forest", name: "Forest Green", accentColorHex: "2D6A4F", gradientStartHex: "1B4332", gradientEndHex: "40916C"),
        AppTheme(id: "lavender", name: "Lavender Dream", accentColorHex: "7209B7", gradientStartHex: "560BAD", gradientEndHex: "B5179E"),
        AppTheme(id: "neon", name: "Neon Nights", accentColorHex: "00F5FF", gradientStartHex: "8338EC", gradientEndHex: "00F5FF"),
        AppTheme(id: "cherry", name: "Cherry Blossom", accentColorHex: "FF006E", gradientStartHex: "D00000", gradientEndHex: "FF006E")
    ]
    
    init() {
        // Load saved preferences
        if let savedThemeId = UserDefaults.standard.string(forKey: "selectedTheme"),
           let theme = themes.first(where: { $0.id == savedThemeId }) {
            self.currentTheme = theme
        } else {
            self.currentTheme = themes[0]
        }
        
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        self.colorScheme = isDarkMode ? .dark : .light
    }
    
    func selectTheme(_ theme: AppTheme) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentTheme = theme
        }
        savePreferences()
    }
    
    private func savePreferences() {
        UserDefaults.standard.set(currentTheme.id, forKey: "selectedTheme")
        UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
    }
}

// Color extension to support hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Glassmorphism effect modifier
struct GlassmorphicCard: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 10, x: 0, y: 5)
            )
    }
}

extension View {
    func glassmorphic() -> some View {
        modifier(GlassmorphicCard())
    }
}
