import SwiftUI

/// A horizontal wavy vine line with small leaf nodes — a decorative
/// section divider, drawn as a plain vector Shape (no image assets),
/// matching FlowerMark/LeafSprigMark's precedent.
struct VineDividerMark: Shape {
    var waveCount: Int = 3
    var leafNodeCount: Int = 4

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // The wavy vine line itself.
        let amplitude = rect.height * 0.35
        let segmentWidth = rect.width / CGFloat(waveCount)
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        for i in 0..<waveCount {
            let segmentStartX = rect.minX + CGFloat(i) * segmentWidth
            let controlY = i.isMultiple(of: 2) ? rect.midY - amplitude : rect.midY + amplitude
            let control = CGPoint(x: segmentStartX + segmentWidth / 2, y: controlY)
            let end = CGPoint(x: segmentStartX + segmentWidth, y: rect.midY)
            path.addQuadCurve(to: end, control: control)
        }

        // Small leaf nodes spaced along the vine.
        for i in 0..<leafNodeCount {
            let t = (CGFloat(i) + 0.5) / CGFloat(leafNodeCount)
            let centerX = rect.minX + t * rect.width
            let leafSize = rect.height * 0.5
            let up = i.isMultiple(of: 2)
            let center = CGPoint(x: centerX, y: up ? rect.midY - leafSize * 0.4 : rect.midY + leafSize * 0.4)

            path.move(to: CGPoint(x: center.x - leafSize / 2, y: center.y))
            path.addQuadCurve(
                to: CGPoint(x: center.x + leafSize / 2, y: center.y),
                control: CGPoint(x: center.x, y: center.y - leafSize * 0.4)
            )
            path.addQuadCurve(
                to: CGPoint(x: center.x - leafSize / 2, y: center.y),
                control: CGPoint(x: center.x, y: center.y + leafSize * 0.4)
            )
        }

        return path
    }
}
