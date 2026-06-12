import SwiftUI
import SwiftData

struct CategoryManagementView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale
    @Query(sort: \Category.name) private var categories: [Category]

    @State private var newName = ""
    @State private var newEmoji = "🏷️"

    var body: some View {
        NavigationStack {
            List {
                Section("新增分类") {
                    HStack {
                        TextField("图标", text: $newEmoji)
                            .frame(width: 44)
                            .multilineTextAlignment(.center)
                        TextField("分类名称", text: $newName)
                        Button("添加") { add() }
                            .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
                Section("已有分类") {
                    if categories.isEmpty {
                        Text("暂无分类").foregroundStyle(.secondary)
                    } else {
                        ForEach(categories) { c in
                            HStack {
                                Text(c.emoji)
                                Text(verbatim: localizedRuntime(c.name, locale))
                                Spacer()
                                Circle().fill(Color(hex: c.colorHex)).frame(width: 16, height: 16)
                            }
                        }
                        .onDelete(perform: delete)
                    }
                }
            }
            .navigationTitle("分类管理")
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .background(Theme.appBackground)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }

    private func add() {
        let name = newName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        context.insert(Category(name: name, emoji: newEmoji.isEmpty ? "🏷️" : newEmoji))
        try? context.save()
        newName = ""
        newEmoji = "🏷️"
        Haptics.success()
    }

    private func delete(_ offsets: IndexSet) {
        for i in offsets { context.delete(categories[i]) }
        try? context.save()
    }
}

#Preview {
    CategoryManagementView()
        .modelContainer(for: [Asset.self, WishItem.self, Category.self], inMemory: true)
}
