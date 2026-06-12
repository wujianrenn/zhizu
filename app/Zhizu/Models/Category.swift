import Foundation
import SwiftData

/// A user-defined category (分类) used for grouping and statistics.
@Model
final class Category {
    var id: UUID = UUID()
    var name: String = ""
    var colorHex: String = "#F58E3C"
    var emoji: String = "🏷️"
    var createdAt: Date = Date()

    init(
        id: UUID = UUID(),
        name: String,
        colorHex: String = "#F58E3C",
        emoji: String = "🏷️",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.emoji = emoji
        self.createdAt = createdAt
    }
}
