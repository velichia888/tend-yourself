import SwiftUI

/// Tend's visual direction: "Small Steps, Brighter Days" — a cream,
/// botanical, hand-illustrated self-care aesthetic (see the ChatGPT
/// mockup set that drove the v2 rebuild). Vector shapes and system fonts
/// throughout — no bundled illustration image assets — following the
/// same hand-drawn-Shape precedent FlowerMark established for v1.
enum Theme {
    // MARK: Colors

    static let ink = Color(red: 0.1098, green: 0.2196, blue: 0.1725)        // #1C3832 deep forest green text
    static let inkSoft = Color(red: 0.349, green: 0.4392, blue: 0.3843)   // #59706E secondary text
    static let inkFaint = Color(red: 0.5843, green: 0.6549, blue: 0.6118) // #95A79C tertiary/placeholder text

    static let surface = Color(red: 1.0, green: 0.9922, blue: 0.9765)      // #FFFDF9 card white
    static let canvas = Color(red: 0.9843, green: 0.9647, blue: 0.9294)    // #FBF6ED cream background
    static let canvasSoft = Color(red: 0.9569, green: 0.9255, blue: 0.851) // #F4ECD9 secondary block wash

    static let borderSubtle = Color(red: 0.8706, green: 0.8314, blue: 0.7529) // #DED4C0

    /// The one bright accent for primary actions and active states.
    static let accent = Color(red: 0.1608, green: 0.4157, blue: 0.298)     // #29694C forest green
    static let accentSoft = Color(red: 0.7686, green: 0.8784, blue: 0.7961) // #C4E0CB

    static let primaryGradient = LinearGradient(
        colors: [Color(red: 0.298, green: 0.5451, blue: 0.4157), accent],
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

        /// Large serif display headings ("Tasks", "Meditation", ...).
        /// System serif design, not a bundled font — gets most of the
        /// mockups' editorial-serif look with zero font-asset risk.
        static func display(_ size: CGFloat) -> SwiftUI.Font {
            .system(size: size, weight: .semibold, design: .serif)
        }

        /// Hand-written accent captions (e.g. "Progress still counts.").
        /// The one bundled font in the project — Caveat, OFL-licensed,
        /// registered via Info.plist's UIAppFonts (Tend/Resources/Fonts,
        /// PostScript name confirmed as "Caveat-Regular"). If the font
        /// ever fails to register, iOS silently substitutes the system
        /// font at this size/weight rather than crashing — verify
        /// visually after any Info.plist or resource-path change.
        static func script(_ size: CGFloat) -> SwiftUI.Font {
            .custom("Caveat-Regular", size: size, relativeTo: .body)
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
