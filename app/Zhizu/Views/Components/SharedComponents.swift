import SwiftUI

/// Rounded card container with subtle shadow, adapts to dark mode.
struct CardContainer<Content: View>: View {
    var padding: CGFloat = 16
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                    .fill(Theme.surface)
            )
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
    }
}

/// A labeled statistic block (title above a large value).
struct StatBlock: View {
    var title: LocalizedStringKey
    var value: String
    var valueColor: Color = .primary
    var alignment: HorizontalAlignment = .leading

    var body: some View {
        VStack(alignment: alignment, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(valueColor)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: alignment == .center ? .center : (alignment == .trailing ? .trailing : .leading))
    }
}

/// A selectable pill/chip used for filters.
struct FilterChip: View {
    @Environment(\.themePalette) private var theme
    var title: LocalizedStringKey
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: {
            Haptics.selection()
            action()
        }) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule().fill(isSelected ? theme.accent : Theme.surfaceSecondary)
                )
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

/// Friendly empty-state placeholder.
struct EmptyStateView: View {
    @Environment(\.themePalette) private var theme
    var systemImage: String
    var title: LocalizedStringKey
    var message: LocalizedStringKey
    var actionTitle: LocalizedStringKey? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 52))
                .foregroundStyle(theme.accent.opacity(0.7))
            Text(title)
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .tint(theme.accent)
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
        .padding(.horizontal, 24)
    }
}

/// Circular icon badge showing an emoji (or SF Symbol) on a tinted background.
struct IconBadge: View {
    var emoji: String
    var sfSymbol: String?
    var size: CGFloat = 44
    var tint: Color = .white.opacity(0.25)

    var body: some View {
        ZStack {
            Circle().fill(tint)
            if let sfSymbol, !sfSymbol.isEmpty {
                Image(systemName: sfSymbol)
                    .font(.system(size: size * 0.5))
                    .foregroundStyle(.white)
            } else {
                Text(emoji)
                    .font(.system(size: size * 0.55))
            }
        }
        .frame(width: size, height: size)
    }
}

/// A small rounded pill label (e.g. "使用中", "128 天").
struct PillLabel: View {
    var text: LocalizedStringKey
    var systemImage: String? = nil
    var background: Color
    var foreground: Color = .white

    var body: some View {
        HStack(spacing: 4) {
            if let systemImage {
                Image(systemName: systemImage)
            }
            Text(text)
        }
        .font(.caption.weight(.semibold))
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Capsule().fill(background))
        .foregroundStyle(foreground)
    }
}
