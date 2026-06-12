import SwiftUI

struct RootTabView: View {
    @State private var selection = 0
    /// Only the assets tab loads at launch; others defer until first visit.
    @State private var loadedTabs: Set<Int> = [0]

    var body: some View {
        TabView(selection: $selection) {
            lazyTab(0) { AssetsView() }
                .tabItem { Label("资产", systemImage: "shippingbox.fill") }

            lazyTab(1) { StatisticsView() }
                .tabItem { Label("统计", systemImage: "chart.pie.fill") }

            lazyTab(2) { WishlistView() }
                .tabItem { Label("心愿单", systemImage: "heart.fill") }

            lazyTab(3) { ProfileView() }
                .tabItem { Label("我的", systemImage: "person.fill") }
        }
        .onChange(of: selection) { _, tab in loadedTabs.insert(tab) }
    }

    @ViewBuilder
    private func lazyTab<Content: View>(_ index: Int, @ViewBuilder content: () -> Content) -> some View {
        Group {
            if loadedTabs.contains(index) {
                content()
            } else {
                Color.clear
            }
        }
        .tag(index)
    }
}

#Preview {
    RootTabView()
        .environmentObject(AppSettings())
        .modelContainer(for: [Asset.self, WishItem.self, Category.self], inMemory: true)
}
