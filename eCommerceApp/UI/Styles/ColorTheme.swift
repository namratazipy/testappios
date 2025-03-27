import SwiftUI

struct ColorTheme {
    static let primary = Color(hex: "FF6B6B")
    static let secondary = Color(hex: "4ECDC4")
    static let accent = Color(hex: "FFE66D")
    static let background = Color(hex: "F7F7F7")
    static let surface = Color.white
    static let text = Color(hex: "2D3436")
    static let textSecondary = Color(hex: "636E72")
    
    // Additional colors for UI elements
    static let success = Color(hex: "00B894")
    static let error = Color(hex: "FF7675")
    static let warning = Color(hex: "FDCB6E")
    static let info = Color(hex: "74B9FF")
    
    // Gradient colors
    static let gradientStart = Color(hex: "FF6B6B")
    static let gradientEnd = Color(hex: "4ECDC4")
}

// Extension to support hex color codes
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
            (a, r, g, b) = (1, 1, 1, 0)
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