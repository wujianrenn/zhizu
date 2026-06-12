import Foundation
import SwiftData

/// An item on the wishlist (心愿单).
@Model
final class WishItem {
    var id: UUID = UUID()
    var name: String = ""
    var price: Double = 0
    var iconEmoji: String = "🎁"
    var targetDate: Date?
    var isRealized: Bool = false
    var createdAt: Date = Date()
    var note: String?

    init(
        id: UUID = UUID(),
        name: String,
        price: Double = 0,
        iconEmoji: String = "🎁",
        targetDate: Date? = nil,
        isRealized: Bool = false,
        createdAt: Date = Date(),
        note: String? = nil
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.iconEmoji = iconEmoji
        self.targetDate = targetDate
        self.isRealized = isRealized
        self.createdAt = createdAt
        self.note = note
    }
}

/// Pure wishlist aggregation helpers (testable without SwiftData).
enum WishlistCalculator {
    static func totalAmount(_ prices: [Double]) -> Double {
        prices.reduce(0, +)
    }

    static func count(_ prices: [Double]) -> Int {
        prices.count
    }
}
