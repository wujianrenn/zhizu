import SwiftUI

/// On-brand SwiftUI launch experience shown briefly over the app on cold start.
/// The system launch screen (generated via `UILaunchScreen_Generation = YES`)
/// remains the real, instant launch surface required by Apple; this view simply
/// adds a short branded splash that fades into the app.
struct LaunchView: View {
    @State private var appeared = false

    var body: some View {
        ZStack {
            Theme.headerGradient
                .ignoresSafeArea()

            VStack(spacing: 18) {
                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(.white.opacity(0.92))
                        .frame(width: 108, height: 108)
                        .shadow(color: .black.opacity(0.12), radius: 14, y: 6)
                    Text("值")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.carrotDeep)
                }
                .scaleEffect(appeared ? 1 : 0.9)
                .opacity(appeared ? 1 : 0)

                VStack(spacing: 4) {
                    Text("值物")
                        .font(.title.weight(.bold))
                        .foregroundStyle(.white)
                    Text("记录拥有，物尽其用")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                }
                .opacity(appeared ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.25)) { appeared = true }
        }
    }
}

#Preview {
    LaunchView()
}
