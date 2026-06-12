import Foundation
import SwiftData

/// JSON DTOs + import/export/clear helpers for the 高级设置 screen.
struct AssetDTO: Codable {
    var id: UUID
    var name: String
    var iconEmoji: String
    var sfSymbol: String?
    var category: String
    var purchaseDate: Date
    var purchasePrice: Double
    var status: String
    var isFavorite: Bool
    var retireDate: Date?
    var salePrice: Double?
    var dailyTarget: Double?
    var createdAt: Date
    var note: String?
}

struct WishDTO: Codable {
    var id: UUID
    var name: String
    var price: Double
    var iconEmoji: String
    var targetDate: Date?
    var isRealized: Bool
    var createdAt: Date
    var note: String?
}

struct CategoryDTO: Codable {
    var id: UUID
    var name: String
    var colorHex: String
    var emoji: String
}

struct ZhizuBackup: Codable {
    var version: Int = 1
    var exportedAt: Date = Date()
    var assets: [AssetDTO]
    var wishes: [WishDTO]
    var categories: [CategoryDTO]
}

enum DataPorter {

    private static func encoder() -> JSONEncoder {
        let e = JSONEncoder()
        e.outputFormatting = [.prettyPrinted, .sortedKeys]
        e.dateEncodingStrategy = .iso8601
        return e
    }

    private static func decoder() -> JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }

    @MainActor
    static func export(context: ModelContext) throws -> Data {
        let assets = (try? context.fetch(FetchDescriptor<Asset>())) ?? []
        let wishes = (try? context.fetch(FetchDescriptor<WishItem>())) ?? []
        let categories = (try? context.fetch(FetchDescriptor<Category>())) ?? []

        let backup = ZhizuBackup(
            assets: assets.map {
                AssetDTO(
                    id: $0.id, name: $0.name, iconEmoji: $0.iconEmoji, sfSymbol: $0.sfSymbol,
                    category: $0.category, purchaseDate: $0.purchaseDate,
                    purchasePrice: $0.purchasePrice, status: $0.statusRaw,
                    isFavorite: $0.isFavorite, retireDate: $0.retireDate,
                    salePrice: $0.salePrice, dailyTarget: $0.dailyTarget,
                    createdAt: $0.createdAt, note: $0.note
                )
            },
            wishes: wishes.map {
                WishDTO(
                    id: $0.id, name: $0.name, price: $0.price, iconEmoji: $0.iconEmoji,
                    targetDate: $0.targetDate, isRealized: $0.isRealized,
                    createdAt: $0.createdAt, note: $0.note
                )
            },
            categories: categories.map {
                CategoryDTO(id: $0.id, name: $0.name, colorHex: $0.colorHex, emoji: $0.emoji)
            }
        )
        return try encoder().encode(backup)
    }

    @MainActor
    @discardableResult
    static func importBackup(_ data: Data, context: ModelContext) throws -> ZhizuBackup {
        let backup = try decoder().decode(ZhizuBackup.self, from: data)
        for dto in backup.categories {
            context.insert(Category(id: dto.id, name: dto.name, colorHex: dto.colorHex, emoji: dto.emoji))
        }
        for dto in backup.assets {
            context.insert(Asset(
                id: dto.id, name: dto.name, iconEmoji: dto.iconEmoji, sfSymbol: dto.sfSymbol,
                category: dto.category, purchaseDate: dto.purchaseDate,
                purchasePrice: dto.purchasePrice,
                status: AssetStatus(rawValue: dto.status) ?? .inUse,
                isFavorite: dto.isFavorite, retireDate: dto.retireDate,
                salePrice: dto.salePrice, dailyTarget: dto.dailyTarget,
                createdAt: dto.createdAt, note: dto.note
            ))
        }
        for dto in backup.wishes {
            context.insert(WishItem(
                id: dto.id, name: dto.name, price: dto.price, iconEmoji: dto.iconEmoji,
                targetDate: dto.targetDate, isRealized: dto.isRealized,
                createdAt: dto.createdAt, note: dto.note
            ))
        }
        try context.save()
        return backup
    }

    @MainActor
    static func clearAll(context: ModelContext) throws {
        try context.delete(model: Asset.self)
        try context.delete(model: WishItem.self)
        try context.delete(model: Category.self)
        try context.save()
    }
}
