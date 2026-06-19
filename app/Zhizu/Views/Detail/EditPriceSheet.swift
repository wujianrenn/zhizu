import SwiftUI
import SwiftData

/// Lightweight sheet to edit an asset's purchase price from the detail hero.
struct EditPriceSheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Bindable var asset: Asset

    @State private var priceText: String

    private var priceValue: Double { Double(priceText) ?? 0 }
    private var isValid: Bool { priceValue > 0 }

    init(asset: Asset) {
        self.asset = asset
        _priceText = State(initialValue: String(asset.purchasePrice))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("购入价格")
                        Spacer()
                        TextField("0.00", text: $priceText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                } footer: {
                    if !priceText.isEmpty && !isValid {
                        Text("价格须大于 0")
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("修改购入价格")
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .background(Theme.appBackground)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }
                        .disabled(!isValid)
                }
            }
        }
    }

    private func save() {
        guard isValid else { return }
        asset.purchasePrice = priceValue
        try? context.save()
        Haptics.success()
        dismiss()
    }
}
