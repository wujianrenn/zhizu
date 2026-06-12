import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    @Environment(\.themePalette) private var theme
    @Environment(\.locale) private var locale
    @Query private var assets: [Asset]
    @State private var range: StatRange = .all
    @State private var showingCategories = false

    /// Cached aggregates — recomputed only when assets or range change.
    @State private var summary = StatsCalculator.PurchaseSaleSummary()
    @State private var distribution: [StatsCalculator.CategoryAmount] = []
    @State private var totalValue: Double = 0
    @State private var totalDaily: Double = 0
    @State private var valueTrend: [(date: Date, value: Double)] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    rangePicker
                    if assets.isEmpty {
                        EmptyStateView(
                            systemImage: "chart.pie",
                            title: "无数据",
                            message: "添加资产后，这里会显示购入、日均与分布统计。"
                        )
                    } else {
                        purchaseSaleCard
                        dailyTotalCard
                        valueTrendCard
                        distributionCard
                        categoryListCard
                    }
                }
                .padding()
                .padding(.bottom, 24)
            }
            .background(Theme.appBackground)
            .navigationTitle("统计")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingCategories = true } label: {
                        Label("分类管理", systemImage: "folder.badge.gearshape")
                    }
                }
            }
            .sheet(isPresented: $showingCategories) { CategoryManagementView() }
            .onAppear { refreshStats() }
            .onChange(of: assets) { _, _ in refreshStats() }
            .onChange(of: range) { _, _ in refreshStats() }
        }
    }

    private func refreshStats() {
        let snapshots = assets.map {
            AssetSnapshot(
                category: $0.category,
                purchaseDate: $0.purchaseDate,
                purchasePrice: $0.purchasePrice,
                isInUse: $0.isInUse,
                retireDate: $0.retireDate,
                salePrice: $0.salePrice,
                dailyCost: $0.dailyCost
            )
        }
        summary = StatsCalculator.purchaseSaleSummary(snapshots, start: range.startDate())
        distribution = StatsCalculator.categoryDistribution(snapshots)
        totalValue = StatsCalculator.totalValue(snapshots)
        totalDaily = StatsCalculator.totalDailyCost(snapshots)
        valueTrend = StatsCalculator.cumulativeValueTrend(snapshots)
    }

    private var rangePicker: some View {
        Picker("时间范围", selection: $range) {
            ForEach(StatRange.allCases) { Text($0.label).tag($0) }
        }
        .pickerStyle(.segmented)
    }

    private var purchaseSaleCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                Text("购入卖出").font(.headline)
                HStack {
                    StatBlock(title: "购入金额", value: Formatters.priceGrouped(summary.purchaseAmount))
                    StatBlock(title: "卖出金额", value: Formatters.priceGrouped(summary.saleAmount))
                }
                HStack {
                    StatBlock(title: "购入件数", value: "\(summary.purchaseCount)")
                    StatBlock(title: "卖出件数", value: "\(summary.saleCount)")
                }
            }
        }
    }

    private var dailyTotalCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                Text("日均总计").font(.headline)
                HStack {
                    StatBlock(title: "日均总额", value: Formatters.dailyCostPerDay(totalDaily, locale: locale))
                    StatBlock(title: "在用资产", value: Formatters.priceGrouped(totalValue))
                }
            }
        }
    }

    private var valueTrendCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                Text("资产总额趋势").font(.headline)
                if valueTrend.count < 2 {
                    Text("数据不足以绘制趋势").font(.caption).foregroundStyle(.secondary)
                } else {
                    Chart(valueTrend, id: \.date) { p in
                        AreaMark(x: .value("日期", p.date), y: .value("总额", p.value))
                            .foregroundStyle(
                                LinearGradient(colors: [theme.accent.opacity(0.4), theme.accent.opacity(0.05)],
                                               startPoint: .top, endPoint: .bottom))
                            .interpolationMethod(.monotone)
                        LineMark(x: .value("日期", p.date), y: .value("总额", p.value))
                            .foregroundStyle(theme.accent)
                            .interpolationMethod(.monotone)
                    }
                    .frame(height: 170)
                }
            }
        }
    }

    private var distributionCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                Text("资产分布").font(.headline)
                if distribution.isEmpty {
                    Text("无数据").font(.caption).foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 120)
                } else {
                    Chart(distribution) { item in
                        SectorMark(
                            angle: .value("金额", item.amount),
                            innerRadius: .ratio(0.62),
                            angularInset: 1.5
                        )
                        .foregroundStyle(by: .value("分类", localizedRuntime(item.category, locale)))
                        .cornerRadius(4)
                    }
                    .chartForegroundStyleScale(range: theme.categoryColors)
                    .chartLegend(position: .bottom, alignment: .center)
                    .frame(height: 220)
                    .overlay {
                        VStack(spacing: 2) {
                            Text("总资产").font(.caption).foregroundStyle(.secondary)
                            Text(Formatters.priceGrouped(totalValue))
                                .font(.headline)
                                .minimumScaleFactor(0.6)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
    }

    private var categoryListCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 10) {
                Text("分类统计").font(.headline)
                if distribution.isEmpty {
                    Text("无数据").font(.caption).foregroundStyle(.secondary)
                } else {
                    ForEach(distribution) { item in
                        HStack {
                            Text(verbatim: localizedRuntime(item.category, locale))
                            Spacer()
                            Text(Formatters.priceGrouped(item.amount))
                                .foregroundStyle(.secondary)
                        }
                        .font(.subheadline)
                        if item.id != distribution.last?.id {
                            Divider()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    StatisticsView()
        .environmentObject(AppSettings())
        .modelContainer(for: [Asset.self, WishItem.self, Category.self], inMemory: true)
}
