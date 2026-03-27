import SwiftUI

// MARK: - Color Palette
struct AppColors {
    // Background gradients
    static let forestGreenDark = Color(hex: "2D5A27")
    static let forestGreenMid = Color(hex: "6B9E5E")
    static let forestGreenLight = Color(hex: "B8D4A8")

    // Accent colors
    static let peach = Color(hex: "E8B89D")
    static let peachDark = Color(hex: "D9A68B")

    // Functional colors
    static let plantGreen = Color(hex: "7BAE7F")
    static let primaryText = Color(hex: "4A403A")
    static let whiteText = Color.white

    // Status colors
    static let healthyGreen = Color(hex: "7BAE7F")
    static let warningYellow = Color(hex: "E8B89D")
    static let alertRed = Color(hex: "DC5050")

    // Status chip backgrounds
    static let healthyChipBg = Color(hex: "7BAE7F").opacity(0.25)
    static let warningChipBg = Color(hex: "E8B89D").opacity(0.25)
    static let alertChipBg = Color(hex: "DC5050").opacity(0.20)

    // Module background gradients
    static let dashboardGradient = LinearGradient(
        colors: [Color(hex: "1A3A1A"), Color(hex: "2D5A27"), Color(hex: "4A7A3F")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let diagnosticsGradient = LinearGradient(
        colors: [Color(hex: "1A1A3A"), Color(hex: "2D2D5A"), Color(hex: "3F3F7A")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let learningGradient = LinearGradient(
        colors: [Color(hex: "3A1A1A"), Color(hex: "5A2D2D"), Color(hex: "7A4A3F")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let analyticsGradient = LinearGradient(
        colors: [Color(hex: "0F2F0F"), Color(hex: "1A4A1A"), Color(hex: "2D6A2D")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    // Glass card backgrounds
    static let glassLight = Color.white.opacity(0.15)
    static let glassMedium = Color.white.opacity(0.22)
    static let glassDark = Color.white.opacity(0.35)
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
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

// MARK: - Typography
struct AppFonts {
    // Headers - using serif system font as Playfair Display substitute
    static func header(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .serif)
    }

    // Body - using rounded system font as Nunito substitute
    static func body(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    static let h1 = header(28)
    static let h2 = header(20)
    static let h3 = header(16)
    static let bodyLarge = body(16, weight: .regular)
    static let bodyRegular = body(14, weight: .regular)
    static let bodySemibold = body(14, weight: .semibold)
    static let bodyBold = body(14, weight: .bold)
    static let caption = body(11, weight: .regular)
    static let captionBold = body(11, weight: .bold)
    static let small = body(10, weight: .regular)
}
