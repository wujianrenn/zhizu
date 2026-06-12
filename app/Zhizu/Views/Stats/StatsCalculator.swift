import Foundation
import SwiftUI

/// Time ranges for the statistics screen.
enum StatRange: String, CaseIterable, Identifiable {
    case week, month, year, all
    var id: String { rawValue }
    var label: LocalizedStringKey {
        switch self {
        case .week: return "周"
        case .month: return "月"
        case .year: return "年"
        case .all: return "全部"
        }
    }

    /// Start date for the range relative to `now` (nil == all time).
    func startDate(now: Date = Date(), calendar: Calendar = .current) -> Date? {
        switch self {
        case .week: return calendar.date(byAdding: .day, value: -7, to: now)
        case .month: return calendar.date(byAdding: .month, value: -1, to: now)
        case .year: return calendar.date(byAdding: .year, value: -1, to: now)
        case .all: return nil
        }
    }
}

/// A lightweight, SwiftData-free snapshot of an asset for aggregation.
struct AssetSnapshot {
    var category: String
    var purchaseDate: Date
    var purchasePrice: Double
    var isInUse: Bool
    var retireDate: Date?
    var salePrice: Double?
    var dailyCost: Double
}

/// Pure aggregation logic for statistics (testable without SwiftData).
enum StatsCalculator {

    struct PurchaseSaleSummary: Equatable {
        var purchaseAmount: Double = 0
        var saleAmount: Double = 0
        var purchaseCount: Int = 0
        var saleCount: Int = 0
    }

    struct CategoryAmount: Identifiable, Equatable {
        var id: String { category }
        var category: String
        var amount: Double
    }

    /// Purchase / sale summary within an optional date window.
    static func purchaseSaleSummary(
        _ assets: [AssetSnapshot],
        start: Date?,
        now: Date = Date()
    ) -> PurchaseSaleSummary {
        var summary = PurchaseSaleSummary()
        for a in assets {
            if inRange(a.purchaseDate, start: start, now: now) {
                summary.purchaseAmount += a.purchasePrice
                summary.purchaseCount += 1
            }
            // Only count toward 卖出 when the user recorded an explicit sale price.
            if let retire = a.retireDate,
               let sale = a.salePrice, sale > 0,
               inRange(retire, start: start, now: now) {
                summary.saleAmount += sale
                summary.saleCount += 1
            }
        }
        return summary
    }

    /// Sum of daily costs across the in-use assets.
    static func totalDailyCost(_ assets: [AssetSnapshot]) -> Double {
        assets.filter(\.isInUse).map(\.dailyCost).reduce(0, +)
    }

    /// Sum of in-use purchase prices.
    static func totalValue(_ assets: [AssetSnapshot]) -> Double {
        assets.filter(\.isInUse).map(\.purchasePrice).reduce(0, +)
    }

    /// Distribution by category (in-use assets only), sorted by amount desc.
    static func categoryDistribution(_ assets: [AssetSnapshot]) -> [CategoryAmount] {
        var totals: [String: Double] = [:]
        for a in assets where a.isInUse {
            totals[a.category, default: 0] += a.purchasePrice
        }
        return totals
            .map { CategoryAmount(category: $0.key, amount: $0.value) }
            .sorted { $0.amount > $1.amount }
    }

    /// Cumulative total asset value over time (one point per acquired asset).
    static func cumulativeValueTrend(_ assets: [AssetSnapshot]) -> [(date: Date, value: Double)] {
        let sorted = assets.sorted { $0.purchaseDate < $1.purchaseDate }
        var running = 0.0
        var points: [(date: Date, value: Double)] = []
        for a in sorted {
            running += a.purchasePrice
            points.append((date: a.purchaseDate, value: running))
        }
        return points
    }

    private static func inRange(_ date: Date, start: Date?, now: Date) -> Bool {
        guard let start else { return date <= now }
        return date >= start && date <= now
    }
}
