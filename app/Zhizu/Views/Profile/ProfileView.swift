import SwiftUI

struct ProfileView: View {
    @Environment(\.themePalette) private var theme

    var body: some View {
        NavigationStack {
            List {
                Section {
                    banner
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                }

                Section {
                    NavigationLink {
                        CustomSettingsView()
                    } label: { rowLabel("自定义设置", "paintbrush.fill", theme.carrot) }

                    NavigationLink {
                        AdvancedSettingsView()
                    } label: { rowLabel("高级设置", "gearshape.2.fill", theme.mutedWarmB) }
                }

                Section {
                    NavigationLink {
                        HelpView()
                    } label: { rowLabel("帮助与反馈", "questionmark.circle.fill", theme.leaf) }

                    NavigationLink {
                        AboutView()
                    } label: { rowLabel("关于我们", "info.circle.fill", theme.coral) }
                }

                Section {
                    Text("物尽其用，物有所值")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("我的")
            .scrollContentBackground(.hidden)
            .background(Theme.appBackground)
        }
    }

    private var banner: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("值物").font(.title.weight(.bold)).foregroundStyle(theme.onBrand)
                Spacer()
                Image(systemName: "checkmark.seal.fill").foregroundStyle(theme.onBrand)
            }
            Text("完全免费 · 无广告 · 无上限")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(theme.onBrand)
            Text("感谢使用，愿你物尽其用、物有所值。")
                .font(.caption)
                .foregroundStyle(theme.onBrandDim)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(theme.headerGradient))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
    }

    private func rowLabel(_ title: LocalizedStringKey, _ symbol: String, _ color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(RoundedRectangle(cornerRadius: 8).fill(color))
            Text(title)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppSettings())
        .modelContainer(for: [Asset.self, WishItem.self, Category.self], inMemory: true)
}
