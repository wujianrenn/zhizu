import SwiftUI

struct HelpView: View {
    private struct FAQ: Identifiable {
        let id = UUID()
        let q: LocalizedStringKey
        let a: LocalizedStringKey
    }

    private let faqs: [FAQ] = [
        FAQ(q: "「日均」是怎么算的？", a: "日均 = 购入价格 ÷ 持有天数。持有越久，日均越低，越「值」。"),
        FAQ(q: "有数量上限吗？", a: "没有。值物完全免费，资产、心愿都不设上限。"),
        FAQ(q: "数据存在哪里？", a: "数据保存在本机（SwiftData）。可在「高级设置」中导出 / 导入 JSON 备份。"),
        FAQ(q: "如何退役资产？", a: "打开资产详情页，点「退役」按钮，可记录退役日期与卖出价格。退役后的物品会出现在资产首页的「已退役」筛选中。")
    ]

    var body: some View {
        List {
            Section("常见问题") {
                ForEach(faqs) { faq in
                    DisclosureGroup(faq.q) {
                        Text(faq.a)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 4)
                    }
                }
            }
            Section("反馈") {
                Label("欢迎把建议告诉我们", systemImage: "envelope")
                Text("这是一个免费、用爱发电的小项目，感谢你的理解与支持。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("帮助与反馈")
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .background(Theme.appBackground)
    }
}

#Preview {
    NavigationStack { HelpView() }
}
