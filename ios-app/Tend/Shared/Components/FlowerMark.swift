import SwiftUI

/// A simple hand-drawn vector flower — a stem plus a five-petal head
/// that scales with `bloomFraction` (0...1). Placeholder visual for v1;
/// see docs/MVP_SCOPE.md. No image assets, no procedural art generation.
struct FlowerMark: Shape {
    var bloomFraction: Double

    var animatableData: Double {
        get { bloomFraction }
        set { bloomFraction = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let clamped = min(max(bloomFraction, 0), 1)

        // Stem
        let stemWidth = rect.width * 0.05
        let stemHeight = rect.height * 0.5
        let stemRect = CGRect(
            x: rect.midX - stemWidth / 2,
            y: rect.midY,
            width: stemWidth,
            height: stemHeight
        )
        path.addRoundedRect(in: stemRect, cornerSize: CGSize(width: stemWidth / 2, height: stemWidth / 2))

        // Flower head: always show at least a small bud so there's
        // something to look at even at bloomFraction == 0.
        let headCenter = CGPoint(x: rect.midX, y: rect.midY - rect.height * 0.02)
        let maxRadius = rect.width * 0.24
        let radius = maxRadius * max(0.22, clamped)
        let petalCount = 5

        for index in 0..<petalCount {
            let angle = (Double(index) / Double(petalCount)) * 2 * .pi - .pi / 2
            let petalCenter = CGPoint(
                x: headCenter.x + CGFloat(cos(angle)) * radius * 0.62,
                y: headCenter.y + CGFloat(sin(angle)) * radius * 0.62
            )
            let petalDiameter = radius * 0.9
            path.addEllipse(in: CGRect(
                x: petalCenter.x - petalDiameter / 2,
                y: petalCenter.y - petalDiameter / 2,
                width: petalDiameter,
                height: petalDiameter
            ))
        }

        // Center
        let centerDiameter = radius * 0.55
        path.addEllipse(in: CGRect(
            x: headCenter.x - centerDiameter / 2,
            y: headCenter.y - centerDiameter / 2,
            width: centerDiameter,
            height: centerDiameter
        ))

        return path
    }
}
