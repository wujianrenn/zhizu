import SwiftUI

/// User-selectable in-app language.
///
/// The app keeps the Chinese source strings as the String Catalog keys, so the
/// development language is `zh-Hans` and English is provided as a translation.
/// Switching is applied live by overriding `\.locale` at the app root.
enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case zhHans
    case en

    var id: String { rawValue }

    /// Locale used to drive both SwiftUI `Text` (via the environment) and any
    /// programmatic `String(localized:)` lookups.
    var locale: Locale {
        switch self {
        case .system: return .autoupdatingCurrent
        case .zhHans: return Locale(identifier: "zh-Hans")
        case .en: return Locale(identifier: "en")
        }
    }

    /// The persisted choice, read directly for non-SwiftUI callers (e.g. the
    /// pure `Formatters` layer) so they can follow the in-app override.
    static var stored: AppLanguage {
        let raw = UserDefaults.standard.string(forKey: "appLanguage") ?? AppLanguage.system.rawValue
        return AppLanguage(rawValue: raw) ?? .system
    }
}

/// Localizes a runtime string used as a key (e.g. a stored category name)
/// against the given locale. Unknown keys (custom user input) resolve to
/// themselves, so user-typed categories display verbatim.
func localizedRuntime(_ key: String, _ locale: Locale) -> String {
    String(localized: String.LocalizationValue(stringLiteral: key), locale: locale)
}
