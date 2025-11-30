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
    @Published var customThemes: [AppTheme] = []
    
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
        // Load custom themes
        if let data = UserDefaults.standard.data(forKey: "customThemes"),
           let decoded = try? JSONDecoder().decode([AppTheme].self, from: data) {
            self.customThemes = decoded
        }
        
        // Load saved preferences
        if let savedThemeId = UserDefaults.standard.string(forKey: "selectedTheme") {
            // Check in predefined themes first
            if let theme = themes.first(where: { $0.id == savedThemeId }) {
                self.currentTheme = theme
            } else if let theme = customThemes.first(where: { $0.id == savedThemeId }) {
                self.currentTheme = theme
            } else {
                self.currentTheme = themes[0]
            }
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
    
    func createCustomTheme(name: String, accentColor: Color, gradientStart: Color, gradientEnd: Color) {
        let theme = AppTheme(
            id: UUID().uuidString,
            name: name,
            accentColorHex: accentColor.toHex() ?? "00B4D8",
            gradientStartHex: gradientStart.toHex() ?? "0077B6",
            gradientEndHex: gradientEnd.toHex() ?? "00B4D8"
        )
        
        customThemes.append(theme)
        saveCustomThemes()
        selectTheme(theme)
    }
    
    func updateCustomTheme(_ theme: AppTheme, name: String, accentColor: Color, gradientStart: Color, gradientEnd: Color) {
        guard let index = customThemes.firstIndex(where: { $0.id == theme.id }) else { return }
        
        let updatedTheme = AppTheme(
            id: theme.id,
            name: name,
            accentColorHex: accentColor.toHex() ?? theme.accentColorHex,
            gradientStartHex: gradientStart.toHex() ?? theme.gradientStartHex,
            gradientEndHex: gradientEnd.toHex() ?? theme.gradientEndHex
        )
        
        customThemes[index] = updatedTheme
        saveCustomThemes()
        
        if currentTheme.id == theme.id {
            selectTheme(updatedTheme)
        }
    }
    
    func deleteCustomTheme(_ theme: AppTheme) {
        customThemes.removeAll { $0.id == theme.id }
        saveCustomThemes()
        
        // If deleted theme was active, switch to default
        if currentTheme.id == theme.id {
            selectTheme(themes[0])
        }
    }
    
    var allThemes: [AppTheme] {
        themes + customThemes
    }
    
    private func savePreferences() {
        UserDefaults.standard.set(currentTheme.id, forKey: "selectedTheme")
        UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
    }
    
    private func saveCustomThemes() {
        if let encoded = try? JSONEncoder().encode(customThemes) {
            UserDefaults.standard.set(encoded, forKey: "customThemes")
        }
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
    
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components else { return nil }
        
        let r = components[0]
        let g = components.count > 1 ? components[1] : components[0]
        let b = components.count > 2 ? components[2] : components[0]
        
        return String(format: "%02lX%02lX%02lX",
                     lroundf(Float(r * 255)),
                     lroundf(Float(g * 255)),
                     lroundf(Float(b * 255)))
    }
}

// Gradient editor helper
struct GradientEditor {
    static func createPreviewGradient(start: Color, end: Color) -> LinearGradient {
        LinearGradient(
            colors: [start, end],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static func suggestedGradients() -> [(String, Color, Color)] {
        [
            ("Warm Sunset", Color(hex: "FF6B6B"), Color(hex: "FFE66D")),
            ("Cool Ocean", Color(hex: "4ECDC4"), Color(hex: "44A08D")),
            ("Purple Haze", Color(hex: "A8C0FF"), Color(hex: "3F2B96")),
            ("Mint Fresh", Color(hex: "00B4DB"), Color(hex: "0083B0")),
            ("Rose Gold", Color(hex: "ED4264"), Color(hex: "FFEDBC")),
            ("Electric Blue", Color(hex: "00D2FF"), Color(hex: "3A7BD5")),
            ("Peachy Keen", Color(hex: "FA709A"), Color(hex: "FEE140")),
            ("Emerald City", Color(hex: "11998E"), Color(hex: "38EF7D"))
        ]
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
