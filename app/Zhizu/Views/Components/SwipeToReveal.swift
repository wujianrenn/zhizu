import SwiftUI

/// A single trailing swipe action.
struct SwipeAction: Identifiable {
    let id: String
    var title: String
    var systemImage: String
    var tint: Color
    var action: () -> Void
}

/// Reusable swipe-to-reveal container for use inside `LazyVStack` (where the
/// native `.swipeActions` modifier — which only works in `List` — is
/// unavailable). Left-swiping the content reveals trailing action buttons while
/// preserving the wrapped view's design. Tapping the content still passes
/// through (e.g. to a `NavigationLink`) when closed; while open, a tap closes
/// the row instead of activating it.
struct SwipeToReveal<Content: View>: View {
    var actions: [SwipeAction]
    /// Corner radius shared with the wrapped card (e.g. `Theme.cardCornerRadius`).
    var cornerRadius: CGFloat = Theme.cardCornerRadius
    /// When this value changes (e.g. parent filter tab), swipe offset resets so
    /// open rows don't bleed through after the list is rebuilt.
    var resetToken: String = ""
    @ViewBuilder var content: () -> Content

    @State private var offset: CGFloat = 0
    @State private var isOpen = false

    private let buttonWidth: CGFloat = 76
    private var revealWidth: CGFloat { CGFloat(actions.count) * buttonWidth }

    var body: some View {
        ZStack(alignment: .trailing) {
            HStack(spacing: 0) {
                ForEach(Array(actions.enumerated()), id: \.element.id) { index, action in
                    actionButton(action, index: index)
                }
            }

            content()
                .offset(x: offset)
                .overlay {
                    if isOpen {
                        // Swallow taps while open so the row closes instead of
                        // activating the underlying NavigationLink.
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture { close() }
                    }
                }
        }
        .clipped()
        .onChange(of: resetToken) { _, _ in
            offset = 0
            isOpen = false
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 24)
                .onChanged { value in
                    guard abs(value.translation.width) > abs(value.translation.height) else { return }
                    let base: CGFloat = isOpen ? -revealWidth : 0
                    offset = min(0, max(-revealWidth - 28, base + value.translation.width))
                }
                .onEnded { value in
                    let base: CGFloat = isOpen ? -revealWidth : 0
                    let projected = base + value.translation.width
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.82)) {
                        if projected < -revealWidth / 2 {
                            offset = -revealWidth
                            isOpen = true
                        } else {
                            offset = 0
                            isOpen = false
                        }
                    }
                }
        )
    }

    private func actionButton(_ action: SwipeAction, index: Int) -> some View {
        let isFirst = index == 0
        let isLast = index == actions.count - 1

        return Button {
            close()
            action.action()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: action.systemImage)
                    .font(.system(size: 17, weight: .semibold))
                Text(action.title)
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(.white)
            .frame(width: buttonWidth)
            .frame(maxHeight: .infinity)
            .background {
                actionShape(isFirst: isFirst, isLast: isLast)
                    .fill(action.tint)
            }
        }
        .buttonStyle(.plain)
    }

    /// Leading corners match the card's trailing radius so the delete strip
    /// nests snugly against the swiped card; trailing corners match the outer edge.
    private func actionShape(isFirst: Bool, isLast: Bool) -> UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            cornerRadii: RectangleCornerRadii(
                topLeading: isFirst ? cornerRadius : 0,
                bottomLeading: isFirst ? cornerRadius : 0,
                bottomTrailing: isLast ? cornerRadius : 0,
                topTrailing: isLast ? cornerRadius : 0
            ),
            style: .continuous
        )
    }

    private func close() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            offset = 0
            isOpen = false
        }
    }
}
