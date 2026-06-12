import SwiftUI

struct CustomSettingsView: View {
    @EnvironmentObject private var settings: AppSettings

    private let accentChoices: [(name: String, hex: String)] = [
        ("薰衣草紫", "#9B8FC7"),
        ("雾紫", "#A99BD4"),
        ("灰蓝紫", "#8E82BE"),
        ("藕荷", "#C68FB0"),
        ("雾金", "#CBB07A"),
        ("鼠尾草绿", "#8FB08C")
    ]
    private let currencyChoices = ["¥", "$", "€", "£", "₩"]

    var body: some View {
        Form {
            languageSection

            appearanceSection

            themeSection

            accentSection

            currencySection
        }
        .navigationTitle("自定义设置")
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .background(Theme.appBackground)
    }

    private var appearanceBinding: Binding<AppearanceMode> {
        Binding(
            get: { settings.appearance },
            set: {
                settings.appearance = $0
                Haptics.selection()
            }
        )
    }

    private var currencyBinding: Binding<String> {
        Binding(
            get: { settings.currencySymbol },
            set: {
                settings.currencySymbol = $0
                settings.applyCurrency()
            }
        )
    }

    private var languageBinding: Binding<AppLanguage> {
        Binding(
            get: { settings.appLanguage },
            set: {
                settings.appLanguage = $0
                Haptics.selection()
            }
        )
    }

    private var languageSection: some View {
        Section {
            Picker("语言", selection: languageBinding) {
                Text("跟随系统").tag(AppLanguage.system)
                Text(verbatim: "简体中文").tag(AppLanguage.zhHans)
                Text(verbatim: "English").tag(AppLanguage.en)
            }
        } header: {
            Text("语言")
        } footer: {
            Text("切换语言会立即生效。")
        }
    }

    private var appearanceSection: some View {
        Section("外观") {
            AppearanceModePicker(selection: appearanceBinding)
                .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
        }
    }

    private var themeSection: some View {
        Section {
            NavigationLink {
                ThemeCustomizationView()
            } label: {
                themeNavigationLabel
            }
        } footer: {
            Text("自定义专属的双色 / 三色渐变，整个 App 即时生效。")
        }
    }

    private var themeNavigationLabel: some View {
        HStack(spacing: 12) {
            Image(systemName: "paintpalette.fill")
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(RoundedRectangle(cornerRadius: 8).fill(settings.palette.accent))
            VStack(alignment: .leading, spacing: 2) {
                Text("自定义配色")
                Text(settings.useCustomPalette ? "已启用自定义渐变" : "使用默认薰衣草")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var accentSection: some View {
        Section {
            HStack(spacing: 16) {
                ForEach(accentChoices, id: \.hex) { choice in
                    accentChoiceButton(choice)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 4)
        } header: {
            Text("强调色")
        } footer: {
            Text("快速强调色（不改变渐变）。选择后会关闭自定义配色。")
        }
    }

    private var currencySection: some View {
        Section("货币符号") {
            Picker("货币符号", selection: currencyBinding) {
                ForEach(currencyChoices, id: \.self) { symbol in
                    Text(symbol).tag(symbol)
                }
            }
            .pickerStyle(.segmented)
            Text("示例：\(settings.currencySymbol)3,599.00")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func accentChoiceButton(_ choice: (name: String, hex: String)) -> some View {
        let isSelected = !settings.useCustomPalette && settings.accentHex == choice.hex

        return Circle()
            .fill(Color(hex: choice.hex))
            .frame(width: 34, height: 34)
            .overlay(
                Circle().stroke(.primary, lineWidth: isSelected ? 3 : 0)
            )
            .onTapGesture {
                settings.useCustomPalette = false
                settings.accentHex = choice.hex
                Haptics.selection()
            }
    }
}

/// Icon-based 跟随系统 / 浅色 / 深色 selector.
struct AppearanceModePicker: View {
    @Binding var selection: AppearanceMode

    private func icon(for mode: AppearanceMode) -> String {
        switch mode {
        case .system: return "gearshape"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }

    var body: some View {
        HStack(spacing: 10) {
            ForEach(AppearanceMode.allCases) { mode in
                let isOn = selection == mode
                VStack(spacing: 6) {
                    Image(systemName: icon(for: mode))
                        .font(.system(size: 20, weight: .semibold))
                    Text(mode.label).font(.caption)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isOn ? Theme.accent.opacity(0.18) : Theme.surfaceSecondary)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Theme.accent, lineWidth: isOn ? 2 : 0)
                )
                .foregroundStyle(isOn ? Theme.accent : .primary)
                .contentShape(Rectangle())
                .onTapGesture { selection = mode }
            }
        }
    }
}

#Preview {
    NavigationStack { CustomSettingsView().environmentObject(AppSettings()) }
}
