import SwiftUI

struct FlowerView: View {
    let stage: GrowthStage
    var size: CGFloat = 180

    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            FlowerMark(bloomFraction: stage.bloomFraction)
                .fill(Theme.color(for: stage))
                .frame(width: size, height: size)
                .animation(.spring(response: 0.6, dampingFraction: 0.75), value: stage)

            Text(stage.label)
                .font(Theme.Font.headline(16))
                .foregroundStyle(Theme.ink)
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        ForEach(GrowthStage.allCases, id: \.self) { stage in
            FlowerView(stage: stage, size: 100)
        }
    }
    .padding()
    .background(Theme.canvas)
}
