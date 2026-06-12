import Foundation

/// Pure, value-based cost & aggregation logic.
///
/// Intentionally free of SwiftData / SwiftUI so it can be unit-tested without a
/// `ModelContainer`. All app aggregation should route through these functions
/// to keep the math in one tested place.
enum CostCalculator {

    // MARK: - Days owned

    /// Number of whole days an asset has been owned.
    ///
    /// - Same-day purchase counts as `1` day (you owned it today).
    /// - A retired asset measures up to its `retireDate`, otherwise up to `now`.
    /// - Never returns less than `1`.
    static func daysOwned(
        purchaseDate: Date,
        retireDate: Date? = nil,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> Int {
        let end = retireDate ?? now
        let startDay = calendar.startOfDay(for: purchaseDate)
        let endDay = calendar.startOfDay(for: end)
        let diff = calendar.dateComponents([.day], from: startDay, to: endDay).day ?? 0
        // +1 so that the purchase day itself counts as a day of ownership.
        return max(1, diff + 1)
    }

    // MARK: - Daily cost

    /// Daily average cost (日均) = price / days owned.
    static func dailyCost(price: Double, days: Int) -> Double {
        let safeDays = Double(max(1, days))
        return price / safeDays
    }

    /// Convenience daily cost from raw dates.
    static func dailyCost(
        price: Double,
        purchaseDate: Date,
        retireDate: Date? = nil,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> Double {
        let days = daysOwned(
            purchaseDate: purchaseDate,
            retireDate: retireDate,
            now: now,
            calendar: calendar
        )
        return dailyCost(price: price, days: days)
    }

    // MARK: - Aggregations

    /// Sum of purchase prices.
    static func totalValue(_ prices: [Double]) -> Double {
        prices.reduce(0, +)
    }

    /// Sum of a list of daily costs.
    static func totalDailyCost(_ dailyCosts: [Double]) -> Double {
        dailyCosts.reduce(0, +)
    }

    // MARK: - Target progress

    /// Progress (0...1) toward a daily-cost target.
    ///
    /// As the asset ages its daily cost falls; progress is how far the *current*
    /// daily cost has descended from the original (day-1) daily cost toward the
    /// target. Reaching or beating the target returns `1`.
    static func targetProgress(
        currentDailyCost: Double,
        originalDailyCost: Double,
        target: Double
    ) -> Double {
        guard target > 0 else { return 0 }
        if currentDailyCost <= target { return 1 }
        // Distance already traveled from start down toward target.
        let span = originalDailyCost - target
        guard span > 0 else { return currentDailyCost <= target ? 1 : 0 }
        let traveled = originalDailyCost - currentDailyCost
        return min(1, max(0, traveled / span))
    }

    // MARK: - Decay curve

    /// Sampled points of the daily-cost decay curve from purchase to end date.
    ///
    /// Returns `(date, dailyCost)` pairs. Useful for the detail-page area chart.
    static func dailyCostCurve(
        price: Double,
        purchaseDate: Date,
        endDate: Date,
        sampleCount: Int = 24,
        calendar: Calendar = .current
    ) -> [(date: Date, dailyCost: Double)] {
        let totalDays = daysOwned(
            purchaseDate: purchaseDate,
            retireDate: endDate,
            calendar: calendar
        )
        let samples = max(2, sampleCount)
        var points: [(date: Date, dailyCost: Double)] = []
        for i in 0..<samples {
            let fraction = Double(i) / Double(samples - 1)
            let dayOffset = max(0, Int((Double(totalDays - 1) * fraction).rounded()))
            let day = dayOffset + 1 // day 1 == purchase day
            let date = calendar.date(byAdding: .day, value: dayOffset, to: purchaseDate) ?? purchaseDate
            points.append((date: date, dailyCost: dailyCost(price: price, days: day)))
        }
        return points
    }
}
