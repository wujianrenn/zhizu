import SwiftUI
import SwiftData

enum WishFilter: String, CaseIterable, Identifiable {
    case all, realized, pending
    var id: String { rawValue }
    var label: LocalizedStringKey {
        switch self {
        case .all: return "全部"
        case .realized: return "已实现"
        case .pending: return "未实现"
        }
    }
}

struct WishlistView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \WishItem.createdAt, order: .reverse) private var wishes: [WishItem]

    @Environment(\.themePalette) private var theme
    @State private var filter: WishFilter = .all
    @State private var showingAdd = false
    @State private var wishPendingDelete: WishItem?

    private var filtered: [WishItem] {
        switch filter {
        case .all: return wishes
        case .realized: return wishes.filter(\.isRealized)
        case .pending: return wishes.filter { !$0.isRealized }
        }
    }

    private var totalAmount: Double { WishlistCalculator.totalAmount(wishes.map(\.price)) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    header
                    filterRow
                    Group {
                        if filtered.isEmpty {
                            EmptyStateView(
                                systemImage: "heart",
                                title: wishes.isEmpty ? "心愿单空空如也" : "没有匹配的心愿",
                                message: wishes.isEmpty ? "把想买的东西记在这里，理性消费，物有所值。" : "换个筛选条件看看。",
                                actionTitle: wishes.isEmpty ? "添加心愿" : nil,
                                action: wishes.isEmpty ? { showingAdd = true } : nil
                            )
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(filtered) { wish in
                                    SwipeToReveal(
                                        actions: swipeActions(for: wish),
                                        resetToken: filter.rawValue
                                    ) {
                                        WishCard(wish: wish, onToggle: { toggleRealized(wish) },
                                                 onConvert: { convertToAsset(wish) },
                                                 onDelete: { wishPendingDelete = wish })
                                    }
                                }
                            }
                        }
                    }
                    .animation(nil, value: filter)
                }
                .padding()
                .padding(.bottom, 24)
            }
            .background(Theme.appBackground)
            .navigationTitle("心愿单")
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingAdd) { WishFormView() }
            .alert(
                "确认删除",
                isPresented: Binding(
                    get: { wishPendingDelete != nil },
                    set: { if !$0 { wishPendingDelete = nil } }
                ),
                presenting: wishPendingDelete
            ) { wish in
                Button("删除", role: .destructive) { delete(wish); wishPendingDelete = nil }
                Button("取消", role: .cancel) { wishPendingDelete = nil }
            } message: { wish in
                Text("确认删除「\(wish.name)」？此操作不可撤销")
            }
        }
    }

    private func swipeActions(for wish: WishItem) -> [SwipeAction] {
        [
            SwipeAction(id: "delete", title: "删除", systemImage: "trash", tint: .red) {
                wishPendingDelete = wish
            }
        ]
    }

    private var header: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "heart.fill")
                        Text("心愿单").font(.title2.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    Text("理性种草，量力而行")
                        .font(.caption).foregroundStyle(.white.opacity(0.85))
                }
                Spacer()
                Button {
                    showingAdd = true
                    Haptics.tap()
                } label: {
                    Label("添加", systemImage: "plus")
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(Capsule().fill(.white.opacity(0.25)))
                        .foregroundStyle(.white)
                }
            }
            HStack(spacing: 12) {
                StatBlock(title: "总金额", value: Formatters.priceGrouped(totalAmount), valueColor: .white)
                Divider().frame(height: 36).overlay(.white.opacity(0.4))
                StatBlock(title: "总数量", value: "\(wishes.count)", valueColor: .white)
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(Theme.wishGradient))
        .padding(.top, 8)
    }

    private var filterRow: some View {
        HStack(spacing: 10) {
            ForEach(WishFilter.allCases) { f in
                FilterChip(title: f.label, isSelected: filter == f) {
                    filter = f
                }
            }
            Spacer()
        }
    }

    private func toggleRealized(_ wish: WishItem) {
        wish.isRealized.toggle()
        try? context.save()
        Haptics.selection()
    }

    private func convertToAsset(_ wish: WishItem) {
        let asset = Asset(
            name: wish.name,
            iconEmoji: wish.iconEmoji,
            category: "其他",
            purchaseDate: Date(),
            purchasePrice: wish.price,
            status: .inUse,
            note: wish.note
        )
        context.insert(asset)
        wish.isRealized = true
        try? context.save()
        Haptics.success()
    }

    private func delete(_ wish: WishItem) {
        context.delete(wish)
        try? context.save()
    }
}

struct WishCard: View {
    @Environment(\.themePalette) private var theme
    @Bindable var wish: WishItem
    var onToggle: () -> Void
    var onConvert: () -> Void
    var onDelete: () -> Void

    var body: some View {
        CardContainer {
            HStack(alignment: .top, spacing: 14) {
                IconBadge(emoji: wish.iconEmoji, sfSymbol: nil, size: 44, tint: theme.accent.opacity(0.18))
                VStack(alignment: .leading, spacing: 4) {
                    Text(wish.name).font(.headline).lineLimit(1)
                    Text(Formatters.price(wish.price)).font(.subheadline).foregroundStyle(.secondary)
                    if let d = wish.targetDate {
                        Text("目标日期 \(Formatters.shortDate(d))")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
                Spacer(minLength: 8)
                // Fixed-height column: button stays at the top; label space is always reserved.
                VStack(spacing: 4) {
                    Button(action: onToggle) {
                        Image(systemName: wish.isRealized ? "checkmark.circle.fill" : "circle")
                            .font(.title2)
                            .foregroundStyle(wish.isRealized ? theme.leaf : .secondary)
                    }
                    .buttonStyle(.plain)
                    Text("已实现")
                        .font(.caption2)
                        .foregroundStyle(wish.isRealized ? theme.leaf : .clear)
                        .accessibilityHidden(!wish.isRealized)
                }
                .frame(width: 52, alignment: .top)
            }
        }
        .contextMenu {
            Button(wish.isRealized ? "标记未实现" : "标记已实现", systemImage: "checkmark.circle", action: onToggle)
            Button("转为资产", systemImage: "shippingbox", action: onConvert)
            Button("删除", systemImage: "trash", role: .destructive, action: onDelete)
        }
    }
}

#Preview {
    WishlistView()
        .environmentObject(AppSettings())
        .modelContainer(for: [Asset.self, WishItem.self, Category.self], inMemory: true)
}
