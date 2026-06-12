import Foundation
import SwiftData

/// A product / asset the user owns.
@Model
final class Asset {
    var id: UUID = UUID()
    var name: String = ""
    var iconEmoji: String = "📦"
    /// Optional SF Symbol name; when set, the UI prefers it over the emoji.
    var sfSymbol: String?
    var category: String = "其他"
    var purchaseDate: Date = Date()
    var purchasePrice: Double = 0
    var statusRaw: String = AssetStatus.inUse.rawValue
    var isFavorite: Bool = false
    var retireDate: Date?
    var salePrice: Double?
    var dailyTarget: Double?
    var createdAt: Date = Date()
    var note: String?

    init(
        id: UUID = UUID(),
        name: String,
        iconEmoji: String = "📦",
        sfSymbol: String? = nil,
        category: String = "其他",
        purchaseDate: Date = Date(),
        purchasePrice: Double = 0,
        status: AssetStatus = .inUse,
        isFavorite: Bool = false,
        retireDate: Date? = nil,
        salePrice: Double? = nil,
        dailyTarget: Double? = nil,
        createdAt: Date = Date(),
        note: String? = nil
    ) {
        self.id = id
        self.name = name
        self.iconEmoji = iconEmoji
        self.sfSymbol = sfSymbol
        self.category = category
        self.purchaseDate = purchaseDate
        self.purchasePrice = purchasePrice
        self.statusRaw = status.rawValue
        self.isFavorite = isFavorite
        self.retireDate = retireDate
        self.salePrice = salePrice
        self.dailyTarget = dailyTarget
        self.createdAt = createdAt
        self.note = note
    }

    // MARK: - Status

    var status: AssetStatus {
        get { AssetStatus(rawValue: statusRaw) ?? .inUse }
        set { statusRaw = newValue.rawValue }
    }

    var isInUse: Bool { status == .inUse }

    // MARK: - Computed cost

    /// Date ownership is measured to: retire date if retired, otherwise now.
    var effectiveEndDate: Date { retireDate ?? Date() }

    var daysOwned: Int {
        CostCalculator.daysOwned(purchaseDate: purchaseDate, retireDate: retireDate)
    }

    var dailyCost: Double {
        CostCalculator.dailyCost(price: purchasePrice, days: daysOwned)
    }

    /// Day-1 daily cost (equal to the purchase price) used as the chart start.
    var originalDailyCost: Double { purchasePrice }

    /// Progress (0...1) toward the daily-cost target, if any.
    var targetProgress: Double? {
        guard let target = dailyTarget, target > 0 else { return nil }
        return CostCalculator.targetProgress(
            currentDailyCost: dailyCost,
            originalDailyCost: originalDailyCost,
            target: target
        )
    }
}

// MARK: - Sorting support

extension Asset: AssetSortable {
    var sortPrice: Double { purchasePrice }
    var sortDailyCost: Double { dailyCost }
    var sortPurchaseDate: Date { purchaseDate }
    var sortDaysOwned: Int { daysOwned }
}
