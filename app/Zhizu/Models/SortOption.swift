import Foundation
import SwiftUI

/// A type whose values can be sorted by the asset list sort options.
///
/// Defined as a protocol so the comparator logic stays pure and testable with
/// lightweight stub values (no SwiftData needed).
protocol AssetSortable {
    var sortPrice: Double { get }
    var sortDailyCost: Double { get }
    var sortPurchaseDate: Date { get }
    var sortDaysOwned: Int { get }
}

/// The field an asset list is sorted by.
enum SortField: String, CaseIterable, Identifiable {
    case dailyCost
    case price
    case purchaseDate
    case daysOwned

    var id: String { rawValue }

    var label: LocalizedStringKey {
        switch self {
        case .dailyCost: return "日均"
        case .price: return "价格"
        case .purchaseDate: return "购入时间"
        case .daysOwned: return "持有天数"
        }
    }

    var systemImage: String {
        switch self {
        case .dailyCost: return "yensign.circle"
        case .price: return "tag"
        case .purchaseDate: return "calendar"
        case .daysOwned: return "clock"
        }
    }
}

/// Sort direction.
enum SortDirection: String, CaseIterable, Identifiable {
    case ascending
    case descending

    var id: String { rawValue }

    var label: LocalizedStringKey { self == .ascending ? "升序" : "降序" }
    var systemImage: String { self == .ascending ? "arrow.up" : "arrow.down" }
}

/// Combined, codable sort option used by the assets screen.
struct SortOption: Equatable {
    var field: SortField = .dailyCost
    var direction: SortDirection = .descending

    /// Pure comparator. Returns the elements sorted per this option.
    func sorted<T: AssetSortable>(_ items: [T]) -> [T] {
        let ascending = direction == .ascending
        return items.sorted { lhs, rhs in
            let result: Bool
            switch field {
            case .dailyCost:
                result = lhs.sortDailyCost < rhs.sortDailyCost
            case .price:
                result = lhs.sortPrice < rhs.sortPrice
            case .purchaseDate:
                result = lhs.sortPurchaseDate < rhs.sortPurchaseDate
            case .daysOwned:
                result = lhs.sortDaysOwned < rhs.sortDaysOwned
            }
            return ascending ? result : !result
        }
    }
}
