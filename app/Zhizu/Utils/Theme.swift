import SwiftUI

/// App-wide colors, gradients and helpers.
///
/// 「薰衣草 / 雾紫」brand palette — an elegant, low-saturation lavender scheme
/// with a soft "Muji / dreamy" feel, easy on the eyes rather than vivid. The
/// app icon stays the orange carrot; in-app, lavender is dominant and a muted
/// warm gold survives only as a small favorites/coin accent that ties back to
/// the icon. All colors live here (plus the `AccentColor` colorset) so views
/// never hard-code brand colors. The semantic token/gradient *names* are kept
/// stable (so they propagate everywhere); only their values changed. Every
/// token has a light + dark variant tuned so neither glares; gradient stops sit
/// close together for calm cards, and surfaces lean cool pale-lavender (light) /
/// cool purple-charcoal (dark).
enum Theme {

    // MARK: - Brand palette tokens (light / dark)

    /// Primary soft lavender (薰衣草紫) — the dominant brand color.
    static let carrot = Color(lightHex: "#9B8FC7", darkHex: "#8B81B5")
    /// Slightly deeper lavender used as a gradient anchor (small gap from `carrot`).
    static let carrotDeep = Color(lightHex: "#8A7DBA", darkHex: "#786DA0")
    /// Paler lilac used as a gradient anchor.
    static let carrotLight = Color(lightHex: "#B6ABD8", darkHex: "#9E94C2")
    /// Dusty periwinkle / soft lilac (secondary gradient companion), desaturated.
    static let amber = Color(lightHex: "#AEA3D3", darkHex: "#938BBE")
    /// Muted warm gold — small favorites & coin accent that ties to the icon.
    static let gold = Color(lightHex: "#CBB07A", darkHex: "#B89C68")
    /// Soft rose / mauve — wishlist / "love" accents.
    static let coral = Color(lightHex: "#C68FB0", darkHex: "#AC7C9A")
    /// Soft sage-green — positive / success accents only.
    static let leaf = Color(lightHex: "#8FB08C", darkHex: "#7E9E7B")
    /// Cool lavender-gray neutrals for retired / disabled states.
    static let mutedWarmA = Color(lightHex: "#A39EB2", darkHex: "#5A5566")
    static let mutedWarmB = Color(lightHex: "#8C8799", darkHex: "#423E4C")

    /// Convenience alias for the brand accent (mirrors the AccentColor asset).
    static let accent = Color("AccentColor")

    // MARK: - Surfaces (cool pale-lavender light / cool purple-charcoal dark)

    /// App background — cool pale lavender-gray in light, cool purple-charcoal in dark.
    static let appBackground = Color(lightHex: "#F5F3F9", darkHex: "#1A181E")
    /// Card / elevated surface.
    static let surface = Color(lightHex: "#FCFBFE", darkHex: "#252330")
    /// Secondary surface for chips, fields and unselected controls.
    static let surfaceSecondary = Color(lightHex: "#ECE8F3", darkHex: "#302C3A")

    // MARK: - Gradients (gentle — small hue/brightness gap between stops)

    /// Primary brand gradient (clay → sand) used on headers & the profile banner.
    static let headerGradient = LinearGradient(
        colors: [carrot, amber],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// In-use asset card gradient (calm, warm clay).
    static let inUseGradient = LinearGradient(
        colors: [carrotDeep, carrot],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Retired asset card gradient (muted warm taupe).
    static let retiredGradient = LinearGradient(
        colors: [mutedWarmA, mutedWarmB],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Favorite asset card gradient (richer lavender → soft mauve); the warm
    /// gold tie shows through the card's subtle gold border rather than the fill.
    static let favoriteGradient = LinearGradient(
        colors: [Color(lightHex: "#8E82BE", darkHex: "#7C70AA"),
                 Color(lightHex: "#B7A6C9", darkHex: "#9A89B0")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Wishlist header gradient (soft coral → apricot) — warm but distinct.
    static let wishGradient = LinearGradient(
        colors: [coral, carrotLight],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Ordered, muted lavender-family palette for categorical charts (donut).
    static let categoryColors: [Color] = [
        carrot, coral, amber, leaf, gold,
        Color(lightHex: "#C3B7DE", darkHex: "#A89BC6"),
        Color(lightHex: "#B59FC4", darkHex: "#9C86AC")
    ]

    static let cardCornerRadius: CGFloat = 18
}

extension Color {
    /// Initialize from a `#RRGGBB` (or `#AARRGGBB`) hex string.
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
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
            (a, r, g, b) = (255, 155, 143, 199) // fallback: muted lavender
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    /// Initialize a dynamic color that resolves differently in light vs dark mode.
    init(lightHex: String, darkHex: String) {
        #if canImport(UIKit)
        self = Color(UIColor { traits in
            UIColor(Color(hex: traits.userInterfaceStyle == .dark ? darkHex : lightHex))
        })
        #else
        self = Color(hex: lightHex)
        #endif
    }

    /// Hex string `#RRGGBB` for persistence.
    var hexString: String {
        #if canImport(UIKit)
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
        #else
        return "#9B8FC7"
        #endif
    }
}
