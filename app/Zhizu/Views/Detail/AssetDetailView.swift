import SwiftUI
import SwiftData
import Charts

struct AssetDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.themePalette) private var theme
    @Environment(\.locale) private var locale
    @Bindable var asset: Asset

    @State private var showingEdit = false
    @State private var showingDeleteAlert = false
    @State private var showingRetireSheet = false

    private var curve: [(date: Date, dailyCost: Double)] {
        CostCalculator.dailyCostCurve(
            price: asset.purchasePrice,
            purchaseDate: asset.purchaseDate,
            endDate: asset.effectiveEndDate
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                hero
                actionButtons
                purchaseCard
                if !asset.isInUse {
                    retireCard
                }
                dailyCostCard
                if let target = asset.dailyTarget, target > 0 {
                    targetCard(target: target)
                }
                if let note = asset.note, !note.isEmpty {
                    CardContainer {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("备注").font(.caption).foregroundStyle(.secondary)
                            Text(note).font(.body)
                        }
                    }
                }
            }
            .padding()
            .padding(.bottom, 24)
        }
        .background(Theme.appBackground)
        .navigationTitle(asset.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showingEdit = true } label: { Image(systemName: "pencil") }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) { showingDeleteAlert = true } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .sheet(isPresented: $showingEdit) { AssetFormView(existing: asset) }
        .sheet(isPresented: $showingRetireSheet) {
            RetireAssetSheet(asset: asset)
        }
        .alert("删除该资产？", isPresented: $showingDeleteAlert) {
            Button("删除", role: .destructive) { delete() }
            Button("取消", role: .cancel) {}
        } message: {
            Text("此操作无法撤销。")
        }
    }

    // MARK: - Hero

    private var heroTextColor: Color { asset.isInUse ? theme.onBrand : .white }

    private var hero: some View {
        VStack(spacing: 12) {
            IconBadge(emoji: asset.iconEmoji, sfSymbol: asset.sfSymbol, size: 72, tint: heroTextColor.opacity(0.3))
            Text(asset.name)
                .font(.title2.weight(.bold))
                .foregroundStyle(heroTextColor)
                .multilineTextAlignment(.center)
            HStack(spacing: 8) {
                PillLabel(text: asset.status.label,
                          systemImage: asset.isInUse ? "checkmark.circle.fill" : "archivebox.fill",
                          background: heroTextColor.opacity(0.22), foreground: heroTextColor)
                PillLabel(text: "\(asset.daysOwned) 天",
                          systemImage: "clock.fill",
                          background: heroTextColor.opacity(0.22), foreground: heroTextColor)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(asset.isInUse ? theme.inUseGradient : theme.retiredGradient)
        )
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button {
                asset.isFavorite.toggle()
                try? context.save()
                Haptics.tap()
            } label: {
                Label(asset.isFavorite ? "已收藏" : "收藏",
                      systemImage: asset.isFavorite ? "heart.fill" : "heart")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(theme.coral)

            Button {
                if asset.isInUse {
                    showingRetireSheet = true
                } else {
                    reactivate()
                }
                Haptics.tap()
            } label: {
                Label(asset.isInUse ? "退役" : "恢复使用",
                      systemImage: asset.isInUse ? "archivebox" : "arrow.uturn.backward")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(asset.isInUse ? theme.accent : theme.leaf)
        }
    }

    private var purchaseCard: some View {
        CardContainer {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("购入时间").font(.caption).foregroundStyle(.secondary)
                    Text(Formatters.date(asset.purchaseDate)).font(.headline)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("购入价格").font(.caption).foregroundStyle(.secondary)
                    Text(Formatters.price(asset.purchasePrice)).font(.headline)
                }
            }
        }
    }

    private var retireCard: some View {
        CardContainer {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("退役日期").font(.caption).foregroundStyle(.secondary)
                    Text(asset.retireDate.map { Formatters.date($0) } ?? "—").font(.headline)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("卖出价格").font(.caption).foregroundStyle(.secondary)
                    if let sale = asset.salePrice, sale > 0 {
                        Text(Formatters.price(sale)).font(.headline)
                    } else {
                        Text("未填写").font(.headline).foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var dailyCostCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                Text("当前日均成本").font(.subheadline).foregroundStyle(.secondary)
                Text(Formatters.dailyCostDetailed(asset.dailyCost))
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.accent)
                Text("已持有 \(asset.daysOwned) 天，成本随时间下降")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                dailyCostChart
                    .frame(height: 160)
            }
        }
    }

    private var dailyCostChart: some View {
        Chart {
            ForEach(curve, id: \.date) { point in
                AreaMark(
                    x: .value("日期", point.date),
                    y: .value("日均", point.dailyCost)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [theme.accent.opacity(0.5), theme.accent.opacity(0.05)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .interpolationMethod(.monotone)

                LineMark(
                    x: .value("日期", point.date),
                    y: .value("日均", point.dailyCost)
                )
                .foregroundStyle(theme.accent)
                .interpolationMethod(.monotone)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
    }

    private func targetCard(target: Double) -> some View {
        let progress = asset.targetProgress ?? 0
        let reached = asset.dailyCost <= target
        return CardContainer {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("日均目标").font(.subheadline).foregroundStyle(.secondary)
                    Spacer()
                    Text(Formatters.dailyCostPerDay(target, locale: locale)).font(.subheadline.weight(.semibold))
                }
                ProgressView(value: progress)
                    .tint(reached ? theme.leaf : theme.accent)
                HStack {
                    Text(reached ? "已达成目标 🎉" : "距离目标还需时间")
                        .font(.caption)
                        .foregroundStyle(reached ? theme.leaf : .secondary)
                    Spacer()
                    Text(Formatters.percent(progress))
                        .font(.caption.weight(.bold))
                        .foregroundStyle(reached ? theme.leaf : theme.accent)
                }
            }
        }
    }

    private func reactivate() {
        asset.status = .inUse
        asset.retireDate = nil
        asset.salePrice = nil
        try? context.save()
    }

    private func delete() {
        context.delete(asset)
        try? context.save()
        Haptics.warning()
        dismiss()
    }
}

/// Optional retire date + sale price when marking an asset as retired.
private struct RetireAssetSheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Bindable var asset: Asset

    @State private var retireDate: Date
    @State private var salePrice: String

    init(asset: Asset) {
        self.asset = asset
        _retireDate = State(initialValue: asset.retireDate ?? Date())
        _salePrice = State(initialValue: asset.salePrice.map { String($0) } ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("退役") {
                    DatePicker("退役日期", selection: $retireDate, displayedComponents: .date)
                    HStack {
                        Text("卖出价格（可选）")
                        Spacer()
                        TextField("0.00", text: $salePrice)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationTitle("退役")
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .background(Theme.appBackground)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("确认") { confirm() }
                }
            }
        }
    }

    private func confirm() {
        asset.status = .retired
        asset.retireDate = retireDate
        if let parsed = Double(salePrice), parsed > 0 {
            asset.salePrice = parsed
        } else {
            asset.salePrice = nil
        }
        try? context.save()
        Haptics.success()
        dismiss()
    }
}
