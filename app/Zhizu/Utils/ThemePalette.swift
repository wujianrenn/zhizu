import SwiftUI

/// A fully-resolved set of brand colors & gradients for the current settings.
///
/// This is the *live* brand layer: it is recomputed from `AppSettings` and
/// pushed into the SwiftUI environment at the app root, so every view that reads
/// `@Environment(\.themePalette)` re-renders instantly when the user edits their
/// custom palette. The default value (`.standard`) mirrors the muted-lavender
/// `Theme` tokens, so without customization the app looks exactly as before.
///
/// Surfaces (`Theme.appBackground` / `surface` / `surfaceSecondary`) and fixed
/// semantic colors (retired gray, wishlist rose, success sage, coin gold) stay
/// on `Theme`; only the user-customizable *brand* gradient + accent flow through
/// here, plus a luminance-aware `onBrand` text color for contrast.
struct ThemePalette {
    var accent: Color

    // Brand gradients.
    var headerGradient: LinearGradient
    var inUseGradient: LinearGradient
    var favoriteGradient: LinearGradient
    var retiredGradient: LinearGradient
    var wishGradient: LinearGradient

    // Semantic accents (kept fixed even with a custom brand palette).
    var gold: Color
    var coral: Color
    var leaf: Color
    var amber: Color
    var carrot: Color
    var mutedWarmB: Color

    var categoryColors: [Color]

    /// Best-contrast text color to use on the brand gradient (white or near-black).
    var onBrand: Color
    /// Dimmed variant of `onBrand` for secondary text on the brand gradient.
    var onBrandDim: Color

    /// The default muted-lavender palette (matches `Theme`'s static tokens).
    static let standard = ThemePalette(
        accent: Theme.accent,
        headerGradient: Theme.headerGradient,
        inUseGradient: Theme.inUseGradient,
        favoriteGradient: Theme.favoriteGradient,
        retiredGradient: Theme.retiredGradient,
        wishGradient: Theme.wishGradient,
        gold: Theme.gold,
        coral: Theme.coral,
        leaf: Theme.leaf,
        amber: Theme.amber,
        carrot: Theme.carrot,
        mutedWarmB: Theme.mutedWarmB,
        categoryColors: Theme.categoryColors,
        onBrand: .white,
        onBrandDim: .white.opacity(0.85)
    )

    /// Build the live palette from the current settings.
    @MainActor
    static func make(settings: AppSettings) -> ThemePalette {
        var palette = ThemePalette.standard

        if settings.useCustomPalette {
            let c1 = settings.customColor1
            let c2 = settings.customColor2
            let c3 = settings.customColor3
            let stops = settings.paletteColorCount >= 3 ? [c1, c2, c3] : [c1, c2]

            let brand = LinearGradient(colors: stops, startPoint: .topLeading, endPoint: .bottomTrailing)
            palette.accent = c1
            palette.carrot = c1
            palette.amber = c2
            palette.headerGradient = brand
            palette.inUseGradient = brand
            palette.favoriteGradient = LinearGradient(
                colors: Array(stops.reversed()),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            palette.categoryColors = stops + Theme.categoryColors
            let onBrand = ThemePalette.bestText(on: stops)
            palette.onBrand = onBrand
            palette.onBrandDim = onBrand.opacity(0.82)
        } else {
            // Honor the simple "强调色" swatch / picker when not using a full palette.
            palette.accent = Color(hex: settings.accentHex)
        }

        return palette
    }

    /// Pick white or near-black text based on the average luminance of the stops.
    static func bestText(on stops: [Color]) -> Color {
        guard !stops.isEmpty else { return .white }
        let avg = stops.map(\.luminance).reduce(0, +) / Double(stops.count)
        return avg > 0.55 ? Color(white: 0.12) : .white
    }
}

// MARK: - Environment plumbing

private struct ThemePaletteKey: EnvironmentKey {
    static let defaultValue = ThemePalette.standard
}

extension EnvironmentValues {
    var themePalette: ThemePalette {
        get { self[ThemePaletteKey.self] }
        set { self[ThemePaletteKey.self] = newValue }
    }
}

// MARK: - Color math helpers

extension Color {
    /// Relative luminance (WCAG) in 0...1.
    var luminance: Double {
        #if canImport(UIKit)
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        func lin(_ c: CGFloat) -> Double {
            let c = Double(c)
            return c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b)
        #else
        return 0.5
        #endif
    }

    /// Return the color with its brightness shifted by `delta` (-1...1).
    func adjustingBrightness(_ delta: Double) -> Color {
        #if canImport(UIKit)
        let ui = UIColor(self)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if ui.getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            return Color(
                hue: Double(h),
                saturation: Double(s),
                brightness: min(1, max(0, Double(b) + delta)),
                opacity: Double(a)
            )
        }
        return self
        #else
        return self
        #endif
    }
}
