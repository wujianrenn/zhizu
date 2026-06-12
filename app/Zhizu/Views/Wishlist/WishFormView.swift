import SwiftUI
import SwiftData

struct WishFormView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.themePalette) private var theme

    var existing: WishItem?

    @State private var name = ""
    @State private var price = ""
    @State private var iconEmoji = "🎁"
    @State private var hasTargetDate = false
    @State private var targetDate = Date()
    @State private var note = ""

    private let emojiChoices = ["🎁","📱","💻","⌚️","🎧","📷","🎮","🥽","⌨️","👟","🧥","🚗","🏠","📚","💍","☕️"]
    private var priceValue: Double { Double(price) ?? 0 }
    private var isValid: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            Form {
                Section("心愿") {
                    TextField("名称", text: $name)
                    HStack {
                        Text("价格")
                        Spacer()
                        TextField("0.00", text: $price)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(emojiChoices, id: \.self) { e in
                                Text(e).font(.title2)
                                    .frame(width: 40, height: 40)
                                    .background(Circle().fill(iconEmoji == e ? theme.accent.opacity(0.25) : Theme.surfaceSecondary))
                                    .onTapGesture { iconEmoji = e; Haptics.selection() }
                            }
                        }
                    }
                }
                Section("计划") {
                    Toggle("设定目标日期", isOn: $hasTargetDate)
                    if hasTargetDate {
                        DatePicker("目标日期", selection: $targetDate, displayedComponents: .date)
                    }
                    TextField("备注（可选）", text: $note, axis: .vertical).lineLimit(1...3)
                }
            }
            .navigationTitle(existing == nil ? "添加心愿" : "编辑心愿")
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .background(Theme.appBackground)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }.disabled(!isValid)
                }
            }
            .onAppear(perform: load)
        }
    }

    private func load() {
        guard let w = existing else { return }
        name = w.name
        price = String(w.price)
        iconEmoji = w.iconEmoji
        if let d = w.targetDate { targetDate = d; hasTargetDate = true }
        note = w.note ?? ""
    }

    private func save() {
        guard isValid else { return }
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        if let w = existing {
            w.name = name
            w.price = priceValue
            w.iconEmoji = iconEmoji
            w.targetDate = hasTargetDate ? targetDate : nil
            w.note = trimmedNote.isEmpty ? nil : trimmedNote
        } else {
            context.insert(WishItem(
                name: name, price: priceValue, iconEmoji: iconEmoji,
                targetDate: hasTargetDate ? targetDate : nil,
                note: trimmedNote.isEmpty ? nil : trimmedNote
            ))
        }
        try? context.save()
        Haptics.success()
        dismiss()
    }
}

#Preview {
    WishFormView()
        .modelContainer(for: [Asset.self, WishItem.self, Category.self], inMemory: true)
}
