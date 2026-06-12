import SwiftUI
import SwiftData

enum AssetFilter: String, CaseIterable, Identifiable {
    case all, inUse, favorite, retired
    var id: String { rawValue }
    var label: LocalizedStringKey {
        switch self {
        case .all: return "全部"
        case .inUse: return "使用中"
        case .favorite: return "收藏中"
        case .retired: return "已退役"
        }
    }
}

struct AssetsView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.themePalette) private var theme
    @Environment(\.locale) private var locale
    @Query(sort: \Asset.createdAt, order: .reverse) private var assets: [Asset]

    @State private var filter: AssetFilter = .all
    @State private var sort = SortOption()
    @State private var searchText = ""
    @State private var showingSearch = false
    @State private var showingAdd = false
    @State private var assetPendingDelete: Asset?

    /// Memoized list — rebuilt only when filter, sort, search, or assets change.
    @State private var displayedAssets: [Asset] = []
    @State private var headerTotalValue: Double = 0
    @State private var headerTotalDaily: Double = 0

    private var retiredAssets: [Asset] { assets.filter { $0.status == .retired } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    header
                    filterRow
                    if showingSearch {
                        searchField
                    }
                    Group {
                        if displayedAssets.isEmpty {
                            EmptyStateView(
                                systemImage: filter == .retired ? "archivebox" : "shippingbox",
                                title: emptyStateTitle,
                                message: emptyStateMessage,
                                actionTitle: assets.isEmpty ? "添加资产" : nil,
                                action: assets.isEmpty ? { showingAdd = true } : nil
                            )
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(displayedAssets) { asset in
                                    SwipeToReveal(
                                        actions: swipeActions(for: asset),
                                        resetToken: filter.rawValue
                                    ) {
                                        NavigationLink(value: asset) {
                                            AssetCard(asset: asset)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }
                    .animation(nil, value: filter)
                    .animation(nil, value: searchText)
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .background(Theme.appBackground)
            .navigationTitle("资产")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Asset.self) { AssetDetailView(asset: $0) }
            .sheet(isPresented: $showingAdd) {
                AssetFormView()
            }
            .alert(
                "确认删除",
                isPresented: Binding(
                    get: { assetPendingDelete != nil },
                    set: { if !$0 { assetPendingDelete = nil } }
                ),
                presenting: assetPendingDelete
            ) { asset in
                Button("删除", role: .destructive) { delete(asset) }
                Button("取消", role: .cancel) { assetPendingDelete = nil }
            } message: { asset in
                Text("确认删除「\(asset.name)」？此操作不可撤销")
            }
            .onAppear { rebuildDisplayedAssets() }
            .onChange(of: filter) { _, _ in rebuildDisplayedAssets() }
            .onChange(of: sort) { _, _ in rebuildDisplayedAssets() }
            .onChange(of: searchText) { _, _ in rebuildDisplayedAssets() }
            .onChange(of: assets) { _, _ in rebuildDisplayedAssets() }
        }
    }

    private func rebuildDisplayedAssets() {
        var list = assets
        switch filter {
        case .all: break
        case .inUse: list = list.filter { $0.isInUse }
        case .favorite: list = list.filter { $0.isFavorite }
        case .retired: list = list.filter { $0.status == .retired }
        }
        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            let q = searchText.lowercased()
            list = list.filter {
                $0.name.lowercased().contains(q) || $0.category.lowercased().contains(q)
            }
        }
        displayedAssets = sort.sorted(list)

        let inUse = assets.filter { $0.isInUse }
        headerTotalValue = CostCalculator.totalValue(inUse.map(\.purchasePrice))
        headerTotalDaily = CostCalculator.totalDailyCost(inUse.map(\.dailyCost))
    }

    private func swipeActions(for asset: Asset) -> [SwipeAction] {
        [
            SwipeAction(id: "delete", title: "删除", systemImage: "trash", tint: .red) {
                assetPendingDelete = asset
            }
        ]
    }

    private func delete(_ asset: Asset) {
        context.delete(asset)
        try? context.save()
        assetPendingDelete = nil
        Haptics.warning()
    }

    private var emptyStateTitle: LocalizedStringKey {
        if assets.isEmpty { return "还没有资产" }
        if filter == .retired && retiredAssets.isEmpty { return "暂无已退役资产" }
        return "没有匹配的资产"
    }

    private var emptyStateMessage: LocalizedStringKey {
        if assets.isEmpty {
            return "点击「添加」记录你的第一件物品，开始计算日均成本。"
        }
        if filter == .retired && retiredAssets.isEmpty {
            return "打开任一资产详情，点「退役」即可将不用的物品移到这里。"
        }
        return "试试调整筛选或搜索条件。"
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("我的资产")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(theme.onBrand)
                    Text("共 \(assets.count) 件 · 完全免费 · 无上限")
                        .font(.caption)
                        .foregroundStyle(theme.onBrandDim)
                }
                Spacer()
                HStack(spacing: 12) {
                    Button {
                        withAnimation { showingSearch.toggle() }
                        Haptics.tap()
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .headerButtonStyle(theme.onBrand)
                    }
                    Button {
                        showingAdd = true
                        Haptics.tap()
                    } label: {
                        Label("添加", systemImage: "plus")
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(theme.onBrand.opacity(0.22)))
                            .foregroundStyle(theme.onBrand)
                    }
                }
            }
            HStack(spacing: 12) {
                StatBlock(title: "总资产", value: Formatters.priceGrouped(headerTotalValue), valueColor: theme.onBrand)
                Divider().frame(height: 36).overlay(theme.onBrand.opacity(0.4))
                StatBlock(title: "总日均", value: Formatters.dailyCostPerDay(headerTotalDaily, locale: locale), valueColor: theme.onBrand)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(theme.headerGradient)
        )
        .padding(.top, 8)
    }

    // MARK: - Filter row

    private var filterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(AssetFilter.allCases) { f in
                    FilterChip(title: f.label, isSelected: filter == f) {
                        filter = f
                    }
                }
                Spacer(minLength: 4)
                sortMenu
            }
            .padding(.vertical, 2)
        }
    }

    private var sortMenu: some View {
        Menu {
            Picker("排序字段", selection: $sort.field) {
                ForEach(SortField.allCases) { field in
                    Label(field.label, systemImage: field.systemImage).tag(field)
                }
            }
            Divider()
            Picker("排序方向", selection: $sort.direction) {
                ForEach(SortDirection.allCases) { dir in
                    Label(dir.label, systemImage: dir.systemImage).tag(dir)
                }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "arrow.up.arrow.down")
                Text(sort.field.label)
            }
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Capsule().fill(Theme.surfaceSecondary))
            .foregroundStyle(.primary)
        }
    }

    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
            TextField("搜索名称或分类", text: $searchText)
                .textInputAutocapitalization(.never)
            if !searchText.isEmpty {
                Button { searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 12).fill(Theme.surfaceSecondary))
    }
}

private extension Image {
    func headerButtonStyle(_ color: Color = .white) -> some View {
        self.font(.system(size: 16, weight: .semibold))
            .foregroundStyle(color)
            .frame(width: 36, height: 36)
            .background(Circle().fill(color.opacity(0.22)))
    }
}

#Preview {
    AssetsView()
        .environmentObject(AppSettings())
        .modelContainer(for: [Asset.self, WishItem.self, Category.self], inMemory: true)
}
