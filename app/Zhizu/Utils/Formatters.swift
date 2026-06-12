import Foundation

/// Centralized money / number / date formatting.
///
/// Kept free of UI dependencies so the formatting rules can be unit-tested.
enum Formatters {

    // MARK: - Currency symbol

    /// Currency symbol used throughout the app. Defaults to RMB.
    static var currencySymbol: String = "¥"

    // MARK: - Number formatters (cached)

    private static func decimalFormatter(min: Int, max: Int, grouping: Bool) -> NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = min
        f.maximumFractionDigits = max
        f.usesGroupingSeparator = grouping
        f.locale = Locale(identifier: "zh_Hans")
        f.roundingMode = .halfUp
        return f
    }

    // MARK: - Prices

    /// Price with 2 decimals, e.g. `¥3599.00`.
    static func price(_ value: Double) -> String {
        let f = decimalFormatter(min: 2, max: 2, grouping: false)
        let number = f.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
        return "\(currencySymbol)\(number)"
    }

    /// Price with grouping separators, e.g. `¥21,593.00`. Used for large totals.
    static func priceGrouped(_ value: Double) -> String {
        let f = decimalFormatter(min: 2, max: 2, grouping: true)
        let number = f.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
        return "\(currencySymbol)\(number)"
    }

    /// Compact price without trailing decimals when whole, e.g. `¥3599`.
    static func priceCompact(_ value: Double) -> String {
        let f = decimalFormatter(min: 0, max: 2, grouping: false)
        let number = f.string(from: NSNumber(value: value)) ?? String(format: "%g", value)
        return "\(currencySymbol)\(number)"
    }

    // MARK: - Daily cost

    /// Daily cost with 2 decimals, e.g. `¥28.12`.
    static func dailyCost(_ value: Double) -> String {
        let f = decimalFormatter(min: 2, max: 2, grouping: false)
        let number = f.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
        return "\(currencySymbol)\(number)"
    }

    /// Higher-precision daily cost for the detail page, e.g. `¥28.117`.
    static func dailyCostDetailed(_ value: Double) -> String {
        let f = decimalFormatter(min: 2, max: 3, grouping: false)
        let number = f.string(from: NSNumber(value: value)) ?? String(format: "%.3f", value)
        return "\(currencySymbol)\(number)"
    }

    /// Daily cost with the `/天` (`/day`) suffix used on cards, e.g. `¥28.12/天`.
    /// Localized against `locale` so the unit reads naturally per language.
    static func dailyCostPerDay(_ value: Double, locale: Locale = AppLanguage.stored.locale) -> String {
        String(localized: "\(dailyCost(value))/天", locale: locale)
    }

    // MARK: - Misc

    /// Percentage from a 0...1 fraction, e.g. `72%`.
    static func percent(_ fraction: Double) -> String {
        let clamped = min(1, max(0, fraction))
        return "\(Int((clamped * 100).rounded()))%"
    }

    /// Days as `128 天` / `128 days` (pluralized in English), localized.
    static func days(_ value: Int, locale: Locale = AppLanguage.stored.locale) -> String {
        String(localized: "\(value) 天", locale: locale)
    }

    // MARK: - Dates

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_Hans")
        f.dateFormat = "yyyy年M月d日"
        return f
    }()

    private static let shortDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_Hans")
        f.dateFormat = "yyyy/M/d"
        return f
    }()

    /// Date as `2026年1月31日`.
    static func date(_ value: Date) -> String {
        dateFormatter.string(from: value)
    }

    /// Date as `2026/1/31`.
    static func shortDate(_ value: Date) -> String {
        shortDateFormatter.string(from: value)
    }
}
