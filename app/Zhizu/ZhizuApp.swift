import SwiftUI
import SwiftData

@main
struct ZhizuApp: App {
    @StateObject private var settings = AppSettings()
    @State private var showLaunch = true

    /// Shared SwiftData container for the whole app.
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: Asset.self, WishItem.self, Category.self)
        } catch {
            fatalError("无法创建 ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                RootTabView()
                    .environmentObject(settings)
                    .environment(\.themePalette, settings.palette)
                    .tint(settings.accentColor)
                    .preferredColorScheme(settings.appearance.colorScheme)
                    .onAppear { settings.applyCurrency() }

                if showLaunch {
                    LaunchView()
                        .transition(.opacity)
                        .zIndex(1)
                        .allowsHitTesting(false)
                }
            }
            .environment(\.locale, settings.resolvedLocale)
            .task {
                // Brief branded splash only — must not block interaction underneath.
                try? await Task.sleep(nanoseconds: 300_000_000)
                withAnimation(.easeOut(duration: 0.25)) { showLaunch = false }
            }
        }
        .modelContainer(container)
    }
}
