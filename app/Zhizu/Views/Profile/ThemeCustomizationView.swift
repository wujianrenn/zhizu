import SwiftUI

struct ThemeCustomizationView: View {
    @EnvironmentObject private var settings: AppSettings

    /// Curated muted 2/3-color presets.
    private struct Preset: Identifiable {
        let id = UUID()
        let name: LocalizedStringKey
        let hexes: [String]
    }

    private let presets: [Preset] = [
        Preset(name: "薰衣草", hexes: ["#9B8FC7", "#B6ABD8"]),
        Preset(name: "靛蓝", hexes: ["#6B6CA8", "#8E86C7", "#B3A8D9"]),
        Preset(name: "雾感青", hexes: ["#6FB3AE", "#9AD0C2"]),
        Preset(name: "落日珊瑚", hexes: ["#E0997A", "#EAB78E", "#F0D2A6"]),
        Preset(name: "玫瑰", hexes: ["#C98AA6", "#E0AFC0"]),
        Preset(name: "晴空蓝", hexes: ["#7FAAD6", "#A9C8E6"]),
        Preset(name: "水墨", hexes: ["#5A5560", "#8C8794"]),
        Preset(name: "鼠尾草", hexes: ["#8FB08C", "#B6CDA8"])
    ]

    // MARK: - Live preview helpers

    private var previewStops: [Color] {
        settings.paletteColorCount >= 3
            ? [settings.customColor1, settings.customColor2, settings.customColor3]
            : [settings.customColor1, settings.customColor2]
    }
    private var previewGradient: LinearGradient {
        LinearGradient(colors: previewStops, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    private var previewOnBrand: Color { ThemePalette.bestText(on: previewStops) }

    var body: some View {
        Form {
            Section("实时预览") {
                previewCard
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                    .listRowBackground(Color.clear)
            }

            Section {
                Toggle("启用自定义配色", isOn: Binding(
                    get: { settings.useCustomPalette },
                    set: { settings.useCustomPalette = $0; Haptics.selection() }
                ))
                Picker("渐变色数", selection: Binding(
                    get: { settings.paletteColorCount },
                    set: { settings.paletteColorCount = $0 }
                )) {
                    Text("双色").tag(2)
                    Text("三色").tag(3)
                }
                .pickerStyle(.segmented)
            } footer: {
                Text("开启后，渐变与强调色将使用你挑选的颜色，整个 App 即时生效。")
            }

            Section("自定义颜色") {
                ColorPicker("主色", selection: colorBinding(\.customColor1), supportsOpacity: false)
                ColorPicker("辅色", selection: colorBinding(\.customColor2), supportsOpacity: false)
                if settings.paletteColorCount >= 3 {
                    ColorPicker("第三色", selection: colorBinding(\.customColor3), supportsOpacity: false)
                }
            }

            Section("预设搭配") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(presets) { preset in
                            presetSwatch(preset)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }

            Section {
                Button(role: .destructive) {
                    settings.resetPalette()
                    Haptics.warning()
                } label: {
                    Label("恢复默认", systemImage: "arrow.counterclockwise")
                }
            }
        }
        .navigationTitle("自定义配色")
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .background(Theme.appBackground)
    }

    // MARK: - Preview card

    private var previewCard: some View {
        VStack(spacing: 14) {
            // Sample header card.
            VStack(alignment: .leading, spacing: 10) {
                Text("我的资产")
                    .font(.headline)
                    .foregroundStyle(previewOnBrand)
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("总资产").font(.caption2).foregroundStyle(previewOnBrand.opacity(0.85))
                        Text("¥21,593").font(.title3.weight(.bold)).foregroundStyle(previewOnBrand)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("总日均").font(.caption2).foregroundStyle(previewOnBrand.opacity(0.85))
                        Text("¥28.12/天").font(.title3.weight(.bold)).foregroundStyle(previewOnBrand)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(previewGradient))

            // Sample asset card.
            HStack(spacing: 12) {
                Text("📱").font(.title2)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(.white.opacity(0.25)))
                VStack(alignment: .leading, spacing: 2) {
                    Text("iPad mini7").font(.subheadline.weight(.semibold)).foregroundStyle(previewOnBrand)
                    Text("¥3599 · ¥28.12/天").font(.caption).foregroundStyle(previewOnBrand.opacity(0.85))
                }
                Spacer()
                Text("128 天").font(.headline).foregroundStyle(previewOnBrand)
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(previewGradient))

            // Sample accent button.
            Button {} label: {
                Text("强调按钮").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(settings.customColor1)
            .disabled(true)
        }
    }

    private func presetSwatch(_ preset: Preset) -> some View {
        let stops = preset.hexes.map { Color(hex: $0) }
        return VStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(LinearGradient(colors: stops, startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 64, height: 44)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(.primary.opacity(0.15), lineWidth: 1)
                )
            Text(preset.name).font(.caption2).foregroundStyle(.secondary)
        }
        .onTapGesture { apply(preset) }
    }

    // MARK: - Actions

    private func colorBinding(_ keyPath: ReferenceWritableKeyPath<AppSettings, Color>) -> Binding<Color> {
        Binding(
            get: { settings[keyPath: keyPath] },
            set: { newValue in
                settings[keyPath: keyPath] = newValue
                settings.useCustomPalette = true
            }
        )
    }

    private func apply(_ preset: Preset) {
        settings.paletteColorCount = preset.hexes.count >= 3 ? 3 : 2
        settings.customColor1Hex = preset.hexes[0]
        settings.customColor2Hex = preset.hexes.count > 1 ? preset.hexes[1] : preset.hexes[0]
        settings.customColor3Hex = preset.hexes.count > 2 ? preset.hexes[2] : preset.hexes[min(1, preset.hexes.count - 1)]
        settings.accentHex = preset.hexes[0]
        settings.useCustomPalette = true
        Haptics.success()
    }
}

#Preview {
    NavigationStack { ThemeCustomizationView().environmentObject(AppSettings()) }
}
