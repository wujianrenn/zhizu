import Foundation
import SwiftUI

/// Lifecycle status of an asset.
enum AssetStatus: String, Codable, CaseIterable, Identifiable {
    case inUse
    case retired

    var id: String { rawValue }

    /// Localized display label.
    var label: LocalizedStringKey {
        switch self {
        case .inUse: return "使用中"
        case .retired: return "已退役"
        }
    }
}
