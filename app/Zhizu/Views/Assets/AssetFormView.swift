import SwiftUI
import SwiftData

struct AssetFormView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.themePalette) private var theme
    @Environment(\.locale) private var locale
    @Query(sort: \Category.name) private var categories: [Category]

    /// When non-nil the form edits an existing asset.
    var existing: Asset?

    @State private var name = ""
    @State private var iconEmoji = "📦"
    @State private var category = "其他"
    @State private var purchaseDate = Date()
    @State private var purchasePrice = ""
    @State private var dailyTarget = ""
    @State private var status: AssetStatus = .inUse
    @State private var isFavorite = false
    @State private var retireDate = Date()
    @State private var hasRetireDate = false
    @State private var salePrice = ""
    @State private var note = ""

    private let emojiChoices = ["📦","📱","📲","💻","⌚️","🎧","📷","🎮","📺","🖥️","⌨️","🖱️","🎸","📚","🚗","🏠","👟","🧥","💍","🛋️","🪑","☕️","🍳","🧸","🎁","🪥","🔋","💡"]

    private var isEditing: Bool { existing != nil }
    private var priceValue: Double { Double(purchasePrice) ?? 0 }
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && priceValue > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    TextField("名称", text: $name)
                    emojiPicker
                    Picker("分类", selection: $category) {
                        ForEach(categoryNames, id: \.self) { Text(verbatim: localizedRuntime($0, locale)).tag($0) }
                    }
                }

                Section("购入") {
                    DatePicker("购入时间", selection: $purchaseDate, displayedComponents: .date)
                    HStack {
                        Text("购入价格")
                        Spacer()
                        TextField("0.00", text: $purchasePrice)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("日均目标（可选）")
                        Spacer()
                        TextField("如 5.00", text: $dailyTarget)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }

                Section("状态") {
                    Picker("状态", selection: $status) {
                        ForEach(AssetStatus.allCases) { Text($0.label).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    Toggle("收藏", isOn: $isFavorite)
                    if status == .retired {
                        Toggle("记录退役日期", isOn: $hasRetireDate)
                        if hasRetireDate {
                            DatePicker("退役日期", selection: $retireDate, displayedComponents: .date)
                        }
                        HStack {
                            Text("卖出价格（可选）")
                            Spacer()
                            TextField("0.00", text: $salePrice)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }

                Section("备注") {
                    TextField("可选备注", text: $note, axis: .vertical)
                        .lineLimit(1...4)
                }

                if isValid {
                    Section {
                        LabeledContent("预计日均") {
                            Text(Formatters.dailyCostPerDay(
                                CostCalculator.dailyCost(
                                    price: priceValue,
                                    purchaseDate: purchaseDate,
                                    retireDate: (status == .retired && hasRetireDate) ? retireDate : nil
                                ),
                                locale: locale
                            ))
                            .foregroundStyle(theme.accent)
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "编辑资产" : "添加资产")
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .background(Theme.appBackground)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }.disabled(!isValid)
                }
            }
            .onAppear(perform: load)
        }
    }

    private var categoryNames: [String] {
        var names = categories.map(\.name)
        if names.isEmpty { names = ["平板","手机","影音","穿戴","电脑","其他"] }
        if !names.contains(category) { names.append(category) }
        return names
    }

    private var emojiPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("图标")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(emojiChoices, id: \.self) { e in
                        Text(e)
                            .font(.title2)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle().fill(iconEmoji == e ? theme.accent.opacity(0.25) : Theme.surfaceSecondary)
                            )
                            .overlay(
                                Circle().stroke(iconEmoji == e ? theme.accent : .clear, lineWidth: 2)
                            )
                            .onTapGesture {
                                iconEmoji = e
                                Haptics.selection()
                            }
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private func load() {
        guard let a = existing else { return }
        name = a.name
        iconEmoji = a.iconEmoji
        category = a.category
        purchaseDate = a.purchaseDate
        purchasePrice = String(a.purchasePrice)
        dailyTarget = a.dailyTarget.map { String($0) } ?? ""
        status = a.status
        isFavorite = a.isFavorite
        if let r = a.retireDate { retireDate = r; hasRetireDate = true }
        salePrice = a.salePrice.map { String($0) } ?? ""
        note = a.note ?? ""
    }

    private func save() {
        guard isValid else { return }
        let target = Double(dailyTarget)
        let parsedSale = Double(salePrice)
        let normalizedSale = (parsedSale != nil && parsedSale! > 0) ? parsedSale : nil
        let resolvedRetire = (status == .retired && hasRetireDate) ? retireDate : nil
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)

        if let a = existing {
            a.name = name
            a.iconEmoji = iconEmoji
            a.category = category
            a.purchaseDate = purchaseDate
            a.purchasePrice = priceValue
            a.dailyTarget = target
            a.status = status
            a.isFavorite = isFavorite
            if status == .inUse {
                a.retireDate = nil
                a.salePrice = nil
            } else {
                a.retireDate = resolvedRetire
                a.salePrice = normalizedSale
            }
            a.note = trimmedNote.isEmpty ? nil : trimmedNote
        } else {
            let a = Asset(
                name: name, iconEmoji: iconEmoji, category: category,
                purchaseDate: purchaseDate, purchasePrice: priceValue,
                status: status, isFavorite: isFavorite,
                retireDate: status == .inUse ? nil : resolvedRetire,
                salePrice: status == .inUse ? nil : normalizedSale,
                dailyTarget: target,
                note: trimmedNote.isEmpty ? nil : trimmedNote
            )
            context.insert(a)
        }
        try? context.save()
        Haptics.success()
        dismiss()
    }
}

#Preview {
    AssetFormView()
        .modelContainer(for: [Asset.self, WishItem.self, Category.self], inMemory: true)
}
