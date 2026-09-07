import SwiftUI

/// A small hand-vectored leaf sprig — a curved stem with 2-3 pointed
/// leaflets — used as a decorative corner/frame ornament. Follows the
/// same plain-Shape, no-image-asset precedent as FlowerMark.
struct LeafSprigMark: Shape {
    /// How many leaflets branch off the stem (2 or 3 reads best).
    var leafletCount: Int = 3

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Stem: a gentle curve from bottom-leading to top-trailing.
        let stemStart = CGPoint(x: rect.minX, y: rect.maxY)
        let stemEnd = CGPoint(x: rect.maxX * 0.7, y: rect.minY)
        let stemControl = CGPoint(x: rect.minX + rect.width * 0.1, y: rect.minY + rect.height * 0.3)
        path.move(to: stemStart)
        path.addQuadCurve(to: stemEnd, control: stemControl)

        // Leaflets: pointed almond shapes branching alternately off the stem.
        for index in 0..<leafletCount {
            let t = (CGFloat(index) + 0.5) / CGFloat(leafletCount)
            let base = pointOnQuadCurve(start: stemStart, control: stemControl, end: stemEnd, t: t)
            let side: CGFloat = index.isMultiple(of: 2) ? 1 : -1
            let leafLength = rect.width * 0.32
            let leafWidth = rect.width * 0.16

            let tip = CGPoint(
                x: base.x + side * leafLength * 0.85,
                y: base.y - leafLength * 0.55
            )
            let controlNear = CGPoint(x: base.x + side * leafWidth, y: base.y - leafLength * 0.15)
            let controlFar = CGPoint(x: base.x + side * leafWidth * 0.2, y: base.y - leafLength * 0.75)

            path.move(to: base)
            path.addQuadCurve(to: tip, control: controlNear)
            path.addQuadCurve(to: base, control: controlFar)
        }

        return path
    }

    private func pointOnQuadCurve(start: CGPoint, control: CGPoint, end: CGPoint, t: CGFloat) -> CGPoint {
        let u = 1 - t
        let x = u * u * start.x + 2 * u * t * control.x + t * t * end.x
        let y = u * u * start.y + 2 * u * t * control.y + t * t * end.y
        return CGPoint(x: x, y: y)
    }
}
