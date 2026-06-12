import SwiftUI
import SwiftData
import UniformTypeIdentifiers

/// Minimal JSON document used for the data-export file dialog.
struct JSONBackupDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var data: Data

    init(data: Data) { self.data = data }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

struct AdvancedSettingsView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.locale) private var locale

    @State private var exportDocument: JSONBackupDocument?
    @State private var showingExporter = false
    @State private var showingImporter = false
    @State private var showingClearAlert = false
    @State private var message: String?

    var body: some View {
        Form {
            Section("数据") {
                Button {
                    exportData()
                } label: { Label("导出数据 (JSON)", systemImage: "square.and.arrow.up") }

                Button {
                    showingImporter = true
                } label: { Label("导入数据 (JSON)", systemImage: "square.and.arrow.down") }
            }

            Section {
                Button(role: .destructive) {
                    showingClearAlert = true
                } label: { Label("清空所有数据", systemImage: "trash") }
            } footer: {
                Text("清空操作会删除全部资产、心愿与分类，且无法撤销。")
            }

            if let message {
                Section { Text(message).font(.footnote).foregroundStyle(.secondary) }
            }
        }
        .navigationTitle("高级设置")
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .background(Theme.appBackground)
        .fileExporter(
            isPresented: $showingExporter,
            document: exportDocument,
            contentType: .json,
            defaultFilename: "Zhizu-Backup-\(Self.dateStamp())"
        ) { result in
            switch result {
            case .success: message = String(localized: "导出成功 ✅", locale: locale)
            case .failure(let error): message = String(localized: "导出失败：\(error.localizedDescription)", locale: locale)
            }
        }
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            handleImport(result)
        }
        .alert("清空所有数据？", isPresented: $showingClearAlert) {
            Button("清空", role: .destructive) { clearData() }
            Button("取消", role: .cancel) {}
        } message: {
            Text("此操作无法撤销。")
        }
    }

    private static func dateStamp() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd"
        return f.string(from: Date())
    }

    private func exportData() {
        do {
            let data = try DataPorter.export(context: context)
            exportDocument = JSONBackupDocument(data: data)
            showingExporter = true
        } catch {
            message = String(localized: "导出失败：\(error.localizedDescription)", locale: locale)
        }
    }

    private func handleImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            let didAccess = url.startAccessingSecurityScopedResource()
            defer { if didAccess { url.stopAccessingSecurityScopedResource() } }
            do {
                let data = try Data(contentsOf: url)
                let backup = try DataPorter.importBackup(data, context: context)
                message = String(localized: "导入成功：\(backup.assets.count) 件资产、\(backup.wishes.count) 条心愿。", locale: locale)
                Haptics.success()
            } catch {
                message = String(localized: "导入失败：\(error.localizedDescription)", locale: locale)
            }
        case .failure(let error):
            message = String(localized: "导入失败：\(error.localizedDescription)", locale: locale)
        }
    }

    private func clearData() {
        do {
            try DataPorter.clearAll(context: context)
            message = String(localized: "已清空所有数据。", locale: locale)
            Haptics.warning()
        } catch {
            message = String(localized: "清空失败：\(error.localizedDescription)", locale: locale)
        }
    }
}

#Preview {
    NavigationStack {
        AdvancedSettingsView()
            .modelContainer(for: [Asset.self, WishItem.self, Category.self], inMemory: true)
    }
}
