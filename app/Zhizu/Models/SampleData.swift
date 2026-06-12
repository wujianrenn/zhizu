import Foundation
import SwiftData

/// First-launch seed data so a fresh install mirrors the reference screenshots.
enum SampleData {

    private static func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var c = DateComponents()
        c.year = year; c.month = month; c.day = day
        return Calendar.current.date(from: c) ?? Date()
    }

    /// Categories used by the seed assets.
    static func makeCategories() -> [Category] {
        [
            Category(name: "平板", colorHex: "#8E7CF5", emoji: "📱"),
            Category(name: "手机", colorHex: "#F5A03C", emoji: "📲"),
            Category(name: "影音", colorHex: "#3CC4F5", emoji: "🎧"),
            Category(name: "穿戴", colorHex: "#F53C7A", emoji: "⌚️"),
            Category(name: "电脑", colorHex: "#42C07A", emoji: "💻"),
            Category(name: "其他", colorHex: "#9AA0A6", emoji: "🏷️")
        ]
    }

    /// The eight example assets (≈ ¥21,593 total purchase value).
    static func makeAssets() -> [Asset] {
        [
            Asset(
                name: "iPad mini7 256 紫",
                iconEmoji: "📱",
                category: "平板",
                purchaseDate: date(2026, 1, 31),
                purchasePrice: 3599,
                status: .inUse,
                isFavorite: true,
                dailyTarget: 5.0,
                note: "随身阅读 + 手绘"
            ),
            Asset(
                name: "大疆 Action 6",
                iconEmoji: "📷",
                category: "影音",
                purchaseDate: date(2025, 11, 11),
                purchasePrice: 2998,
                status: .inUse
            ),
            Asset(
                name: "AirPods 4 主动降噪版",
                iconEmoji: "🎧",
                category: "影音",
                purchaseDate: date(2025, 9, 20),
                purchasePrice: 1399,
                status: .inUse,
                dailyTarget: 3.0
            ),
            Asset(
                name: "iPhone 17 lavender",
                iconEmoji: "📱",
                category: "手机",
                purchaseDate: date(2025, 9, 30),
                purchasePrice: 5999,
                status: .inUse,
                isFavorite: true,
                dailyTarget: 10.0,
                note: "主力机"
            ),
            Asset(
                name: "漫步者颈挂耳机 X200",
                iconEmoji: "🎧",
                category: "影音",
                purchaseDate: date(2025, 5, 1),
                purchasePrice: 98,
                status: .inUse
            ),
            Asset(
                name: "Mac M2 Pro 16+512",
                iconEmoji: "💻",
                category: "电脑",
                purchaseDate: date(2024, 3, 15),
                purchasePrice: 5500,
                status: .inUse,
                isFavorite: true,
                dailyTarget: 8.0,
                note: "干活主力"
            ),
            Asset(
                name: "iPhone 11 紫色 128",
                iconEmoji: "📱",
                category: "手机",
                purchaseDate: date(2023, 9, 20),
                purchasePrice: 1200,
                status: .retired,
                retireDate: date(2025, 10, 1),
                salePrice: 800,
                note: "已升级到 iPhone 17"
            ),
            Asset(
                name: "Apple Watch S7",
                iconEmoji: "⌚️",
                category: "穿戴",
                purchaseDate: date(2024, 6, 10),
                purchasePrice: 800,
                status: .inUse
            )
        ]
    }

    static func makeWishItems() -> [WishItem] {
        [
            WishItem(name: "iPhone 17 Pro Max", price: 9999, iconEmoji: "📱",
                     targetDate: date(2026, 10, 1), isRealized: false, note: "再等等"),
            WishItem(name: "Apple Vision Pro", price: 29999, iconEmoji: "🥽",
                     targetDate: date(2027, 1, 1), isRealized: false),
            WishItem(name: "机械键盘 HHKB", price: 1899, iconEmoji: "⌨️",
                     targetDate: nil, isRealized: true)
        ]
    }

    /// Seeds the context once. The caller is responsible for the first-launch guard.
    @MainActor
    static func seed(into context: ModelContext) {
        for category in makeCategories() { context.insert(category) }
        for asset in makeAssets() { context.insert(asset) }
        for wish in makeWishItems() { context.insert(wish) }
        try? context.save()
    }
}
