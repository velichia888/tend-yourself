import SwiftUI

/// Tend's visual direction: calm, soil-and-garden toned. First,
/// functional pass — system-rounded fonts, a hand-drawn vector flower
/// mark, no bundled illustration assets. A fuller illustrated pass comes
/// later, the same way myemptycloset and Car Hopping got one after their
/// first working builds.
enum Theme {
    // MARK: Colors

    static let ink = Color(red: 0.2039, green: 0.1804, blue: 0.1333)        // #342E22 warm soil brown text
    static let inkSoft = Color(red: 0.4706, green: 0.4392, blue: 0.3765)   // #78705F secondary text
    static let inkFaint = Color(red: 0.698, green: 0.6706, blue: 0.6118)   // #B2AB9C tertiary/placeholder text

    static let surface = Color(red: 0.9922, green: 0.9843, blue: 0.9647)   // #FDFBF6 card white
    static let canvas = Color(red: 0.9569, green: 0.9412, blue: 0.898)     // #F4F0E5 warm parchment background
    static let canvasSoft = Color(red: 0.902, green: 0.8745, blue: 0.7961) // #E6DFCB secondary block wash

    static let borderSubtle = Color(red: 0.8235, green: 0.7882, blue: 0.698) // #D2C9B2

    /// The one bright accent for primary actions and active states.
    static let accent = Color(red: 0.2588, green: 0.5451, blue: 0.3608)    // #428B5C garden green
    static let accentSoft = Color(red: 0.7529, green: 0.8706, blue: 0.7451) // #C0DEBE

    static let primaryGradient = LinearGradient(
        colors: [Color(red: 0.4157, green: 0.6706, blue: 0.4784), accent],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let danger = Color(red: 0.7412, green: 0.1882, blue: 0.1882)
    static let dangerSoft = Color(red: 1.0, green: 0.8824, blue: 0.8824)
    static let success = Color(red: 0.1804, green: 0.5333, blue: 0.2745)
    static let successSoft = Color(red: 0.8706, green: 0.9569, blue: 0.8784)

    static let cardShadow = Color(red: 0.2, green: 0.18, blue: 0.13).opacity(0.12)

    // MARK: Growth stage colors

    /// Presentation intensity only — the underlying claim is always the
    /// same disclosed, deterministic formula (docs/GROWTH.md).
    static func color(for stage: GrowthStage) -> Color {
        switch stage {
        case .seed: return Color(red: 0.549, green: 0.4471, blue: 0.3255)       // soil brown
        case .sprout: return Color(red: 0.5765, green: 0.7098, blue: 0.4471)    // young green
        case .stem: return Color(red: 0.3804, green: 0.6275, blue: 0.3608)      // fuller green
        case .bud: return Color(red: 0.7686, green: 0.5333, blue: 0.6118)       // dusty pink-green
        case .openingBloom: return Color(red: 0.8784, green: 0.4392, blue: 0.5333) // opening pink
        case .fullBloom: return Color(red: 0.9137, green: 0.298, blue: 0.4157)  // full bloom magenta
        }
    }

    // MARK: Spacing / radii

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    static let cornerRadius: CGFloat = 20
    static let cornerRadiusSmall: CGFloat = 16

    // MARK: Typography

    enum Font {
        static func headline(_ size: CGFloat) -> SwiftUI.Font {
            .system(size: size, weight: .bold, design: .rounded)
        }

        static func body(_ size: CGFloat = 16) -> SwiftUI.Font {
            .system(size: size, weight: .regular, design: .default)
        }
    }
}

extension View {
    func cardStyle(cornerRadius: CGFloat = Theme.cornerRadiusSmall) -> some View {
        background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: Theme.cardShadow, radius: 14, x: 0, y: 6)
    }
}
