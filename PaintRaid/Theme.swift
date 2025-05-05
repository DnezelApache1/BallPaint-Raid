import SwiftUI

struct Theme {
    // MARK: - Colors
    static let deepPurple = Color(hex: "5A189A")
    static let lightPurple = Color(hex: "C77DFF")
    static let midPurple = Color(hex: "7B2CBF")
    static let lavender = Color(hex: "E0AAFF")
    static let darkBackground = Color(hex: "240046")
    
    // MARK: - Gradients
    static let primaryGradient = LinearGradient(
        gradient: Gradient(colors: [deepPurple, midPurple, lightPurple]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let purpleGlow = LinearGradient(
        gradient: Gradient(colors: [lightPurple.opacity(0.5), lavender.opacity(0.2)]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    // MARK: - Shapes
    static let cornerRadius: CGFloat = 16
    static let largeCornerRadius: CGFloat = 24
    
    // MARK: - Shadow
    static let shadowRadius: CGFloat = 10
    static let shadowOpacity: CGFloat = 0.3
    static let shadowOffset = CGSize(width: 2, height: 4)
    static let shadowColor = Color.purple.opacity(0.5)
    
    // MARK: - Text Styles
    static let titleFont = Font.system(.title, design: .rounded).weight(.bold)
    static let headlineFont = Font.system(.headline, design: .rounded).weight(.semibold)
    static let bodyFont = Font.system(.body, design: .rounded)
    static let captionFont = Font.system(.caption, design: .rounded)
}

// MARK: - Color Extension for Hex Support
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
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 