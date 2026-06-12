import SwiftUI

struct AboutView: View {
    private var version: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(v) (\(b))"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Theme.wishGradient)
                        Text("值")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 96, height: 96)
                    .shadow(radius: 6)
                    Text("值物").font(.title.weight(.bold))
                    Text("Zhizu · v\(version)").font(.subheadline).foregroundStyle(.secondary)
                }
                .padding(.top, 24)

                CardContainer {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("关于「值物」").font(.headline)
                        Text("「值物」取「物有所值、物尽其用」之意，又谐音「植物」，呼应那只小胡萝卜吉祥物。这只胡萝卜也是向五月天阿信的「卜卜」致敬——我们做了去真人化的原创设计。买之前想清楚，买之后好好用，就是对每件物品最大的尊重。")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                CardContainer {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("我们的理念").font(.headline)
                        Label("完全免费，没有内购、没有会员墙", systemImage: "gift.fill")
                        Label("记录不设上限，想记多少记多少", systemImage: "infinity")
                        Label("用「日均成本」帮你理性看待每件物品", systemImage: "chart.line.downtrend.xyaxis")
                        Label("数据存在本地，导出导入由你掌控", systemImage: "lock.shield.fill")
                    }
                    .font(.subheadline)
                }

                Text("用心做的免费小工具，愿你买得开心、用得长久。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 24)
            }
            .padding()
        }
        .background(Theme.appBackground)
        .navigationTitle("关于我们")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { AboutView() }
}
