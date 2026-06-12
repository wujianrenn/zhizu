import SwiftUI

/// User-facing appearance preference.
enum AppearanceMode: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var label: LocalizedStringKey {
        switch self {
        case .system: return "跟随系统"
        case .light: return "浅色"
        case .dark: return "深色"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

/// Observable, persisted app settings (theme, currency, accent, language).
///
/// Each setting is a `@Published` property backed by `UserDefaults`: it is
/// loaded once in `init()` and persisted in `didSet`. `@Published` integrates
/// with SwiftUI's transaction model correctly — the new value is committed to
/// the property *before* dependent views re-render — so bound controls
/// (Toggle, Picker, ColorPicker, the language picker) update on the **first**
/// interaction, and the app root re-renders live for theme / appearance /
/// accent / locale. (The previous `@AppStorage` + manual
/// `willSet { objectWillChange.send() }` fired the change notification *before*
/// the value was stored, so controls rendered the stale value and felt laggy.)
@MainActor
final class AppSettings: ObservableObject {
    private let defaults = UserDefaults.standard

    @Published var appearanceRaw: String { didSet { defaults.set(appearanceRaw, forKey: Keys.appearance) } }
    @Published var currencySymbol: String { didSet { defaults.set(currencySymbol, forKey: Keys.currency) } }
    @Published var accentHex: String { didSet { defaults.set(accentHex, forKey: Keys.accentHex) } }
    @Published var appLanguageRaw: String { didSet { defaults.set(appLanguageRaw, forKey: Keys.appLanguage) } }

    // MARK: - Custom brand palette

    @Published var useCustomPalette: Bool { didSet { defaults.set(useCustomPalette, forKey: Keys.useCustomPalette) } }
    @Published var paletteColorCount: Int { didSet { defaults.set(paletteColorCount, forKey: Keys.paletteColorCount) } }
    @Published var customColor1Hex: String { didSet { defaults.set(customColor1Hex, forKey: Keys.customColor1) } }
    @Published var customColor2Hex: String { didSet { defaults.set(customColor2Hex, forKey: Keys.customColor2) } }
    @Published var customColor3Hex: String { didSet { defaults.set(customColor3Hex, forKey: Keys.customColor3) } }

    /// Cached palette — rebuilt only when theme-related settings change.
    private var cachedPalette: ThemePalette?
    private var paletteCacheKey: String = ""

    private enum Keys {
        static let appearance = "appearanceMode"
        static let currency = "currencySymbol"
        static let accentHex = "accentHex"
        static let appLanguage = "appLanguage"
        static let useCustomPalette = "useCustomPalette"
        static let paletteColorCount = "paletteColorCount"
        static let customColor1 = "customColor1Hex"
        static let customColor2 = "customColor2Hex"
        static let customColor3 = "customColor3Hex"
    }

    init() {
        // Assigning in init does not trigger `didSet`, so no redundant writes.
        appearanceRaw = defaults.string(forKey: Keys.appearance) ?? AppearanceMode.system.rawValue
        currencySymbol = defaults.string(forKey: Keys.currency) ?? "¥"
        accentHex = defaults.string(forKey: Keys.accentHex) ?? "#9B8FC7"
        appLanguageRaw = defaults.string(forKey: Keys.appLanguage) ?? AppLanguage.system.rawValue
        useCustomPalette = defaults.object(forKey: Keys.useCustomPalette) as? Bool ?? false
        paletteColorCount = defaults.object(forKey: Keys.paletteColorCount) as? Int ?? 2
        customColor1Hex = defaults.string(forKey: Keys.customColor1) ?? "#9B8FC7"
        customColor2Hex = defaults.string(forKey: Keys.customColor2) ?? "#B6ABD8"
        customColor3Hex = defaults.string(forKey: Keys.customColor3) ?? "#C68FB0"
    }

    var appLanguage: AppLanguage {
        get { AppLanguage(rawValue: appLanguageRaw) ?? .system }
        set { appLanguageRaw = newValue.rawValue }
    }

    /// Locale to inject at the app root so `Text` (and date/number formatters)
    /// follow the in-app language choice; `system` follows the device.
    var resolvedLocale: Locale { appLanguage.locale }

    var customColor1: Color {
        get { Color(hex: customColor1Hex) }
        set { customColor1Hex = newValue.hexString }
    }
    var customColor2: Color {
        get { Color(hex: customColor2Hex) }
        set { customColor2Hex = newValue.hexString }
    }
    var customColor3: Color {
        get { Color(hex: customColor3Hex) }
        set { customColor3Hex = newValue.hexString }
    }

    var appearance: AppearanceMode {
        get { AppearanceMode(rawValue: appearanceRaw) ?? .system }
        set { appearanceRaw = newValue.rawValue }
    }

    /// Accent color used for `.tint` and the live palette.
    var accentColor: Color {
        useCustomPalette ? customColor1 : Color(hex: accentHex)
    }

    /// The live, resolved brand palette for the current settings (cached).
    var palette: ThemePalette {
        let key = "\(useCustomPalette)|\(paletteColorCount)|\(customColor1Hex)|\(customColor2Hex)|\(customColor3Hex)|\(accentHex)"
        if key == paletteCacheKey, let cachedPalette { return cachedPalette }
        let built = ThemePalette.make(settings: self)
        cachedPalette = built
        paletteCacheKey = key
        return built
    }

    /// Restore the default muted-lavender palette.
    func resetPalette() {
        useCustomPalette = false
        paletteColorCount = 2
        customColor1Hex = "#9B8FC7"
        customColor2Hex = "#B6ABD8"
        customColor3Hex = "#C68FB0"
        accentHex = "#9B8FC7"
    }

    /// Push the chosen currency symbol into the shared formatter.
    func applyCurrency() {
        Formatters.currencySymbol = currencySymbol
    }
}
