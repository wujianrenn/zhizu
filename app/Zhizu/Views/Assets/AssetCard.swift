import SwiftUI

struct AssetCard: View {
    @Environment(\.themePalette) private var theme
    @Environment(\.locale) private var locale
    let asset: Asset

    private var gradient: LinearGradient {
        guard asset.isInUse else { return theme.retiredGradient }
        return asset.isFavorite ? theme.favoriteGradient : theme.inUseGradient
    }

    /// Retired cards use the fixed gray gradient (white reads fine); in-use /
    /// favorite cards use the brand gradient, so pick contrast automatically.
    private var textColor: Color { asset.isInUse ? theme.onBrand : .white }
    private var dimColor: Color { asset.isInUse ? theme.onBrandDim : .white.opacity(0.85) }

    var body: some View {
        HStack(spacing: 14) {
            IconBadge(emoji: asset.iconEmoji, sfSymbol: asset.sfSymbol, size: 48)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(asset.name)
                        .font(.headline)
                        .foregroundStyle(textColor)
                        .lineLimit(1)
                    if asset.isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundStyle(textColor)
                    }
                }
                Text("\(Formatters.priceCompact(asset.purchasePrice)) · \(Formatters.dailyCostPerDay(asset.dailyCost, locale: locale))")
                    .font(.subheadline)
                    .foregroundStyle(dimColor)
                    .lineLimit(1)
                if !asset.isInUse {
                    PillLabel(text: "已退役", background: .white.opacity(0.25))
                }
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(asset.daysOwned)")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(textColor)
                Text("持有天数")
                    .font(.caption2)
                    .foregroundStyle(dimColor)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                .fill(gradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                .strokeBorder(theme.gold.opacity(asset.isFavorite && asset.isInUse ? 0.55 : 0), lineWidth: 1.5)
        )
        .shadow(color: .black.opacity(0.06), radius: 5, x: 0, y: 2)
    }
}
