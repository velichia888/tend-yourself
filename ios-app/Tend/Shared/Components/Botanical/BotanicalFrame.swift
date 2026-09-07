import SwiftUI

/// Overlays LeafSprigMark ornaments at screen corners, matching the
/// mockups' leaf-framed header treatment. Applied to a screen's
/// outermost ScrollView/VStack, not to individual cards.
struct BotanicalFrame: ViewModifier {
    enum Corners {
        case topLeadingOnly
        case topBothCorners
        case allCorners
    }

    var corners: Corners = .topLeadingOnly
    var size: CGFloat = 72
    var opacity: Double = 0.9

    func body(content: Content) -> some View {
        content.overlay(alignment: .topLeading) {
            sprig
                .rotationEffect(.degrees(-8))
                .frame(width: size, height: size)
                .allowsHitTesting(false)
        }
        .overlay(alignment: .topTrailing) {
            if corners != .topLeadingOnly {
                sprig
                    .scaleEffect(x: -1, y: 1)
                    .rotationEffect(.degrees(8))
                    .frame(width: size, height: size)
                    .allowsHitTesting(false)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if corners == .allCorners {
                sprig
                    .rotationEffect(.degrees(172))
                    .frame(width: size, height: size)
                    .allowsHitTesting(false)
            }
        }
    }

    private var sprig: some View {
        LeafSprigMark()
            .fill(FeatureCategory.wellness.color)
            .opacity(opacity)
    }
}

extension View {
    /// Frames a screen with decorative leaf-sprig ornaments at its
    /// corners, matching the mockups' botanical header treatment.
    func botanicalFrame(
        corners: BotanicalFrame.Corners = .topLeadingOnly,
        size: CGFloat = 72,
        opacity: Double = 0.9
    ) -> some View {
        modifier(BotanicalFrame(corners: corners, size: size, opacity: opacity))
    }
}
