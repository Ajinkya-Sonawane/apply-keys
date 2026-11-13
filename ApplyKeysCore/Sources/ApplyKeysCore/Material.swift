import SwiftUI

/// Material Design 3 colour roles in a pastel scheme, shared by the app and the keyboard.
public struct Palette: Sendable {
    public let primary: Color
    public let onPrimary: Color
    public let primaryContainer: Color
    public let onPrimaryContainer: Color
    public let secondaryContainer: Color
    public let onSecondaryContainer: Color
    public let tertiaryContainer: Color
    public let onTertiaryContainer: Color
    public let surface: Color
    /// A surface that stays lighter than its backdrop in both appearances.
    public let surfaceBright: Color
    public let surfaceContainer: Color
    public let surfaceContainerHigh: Color
    public let onSurface: Color
    public let onSurfaceVariant: Color
    public let outline: Color
    public let outlineVariant: Color
    public let error: Color

    public static func resolve(_ scheme: ColorScheme) -> Palette {
        scheme == .dark ? dark : light
    }

    /// Each tab has its own pastel: lavender for Me, mint for Links, peach for Answers.
    public func container(for tab: SnippetTab) -> Color {
        switch tab {
        case .me: primaryContainer
        case .links: secondaryContainer
        case .answers: tertiaryContainer
        }
    }

    public func onContainer(for tab: SnippetTab) -> Color {
        switch tab {
        case .me: onPrimaryContainer
        case .links: onSecondaryContainer
        case .answers: onTertiaryContainer
        }
    }

    static let light = Palette(
        primary: Color(hex: 0x65558F), onPrimary: Color(hex: 0xFFFFFF),
        primaryContainer: Color(hex: 0xE9DDFF), onPrimaryContainer: Color(hex: 0x211047),
        secondaryContainer: Color(hex: 0xD3EDE1), onSecondaryContainer: Color(hex: 0x0E2A20),
        tertiaryContainer: Color(hex: 0xFFDDCC), onTertiaryContainer: Color(hex: 0x3A1C0A),
        surface: Color(hex: 0xFDF8FF), surfaceBright: Color(hex: 0xFDF8FF),
        surfaceContainer: Color(hex: 0xF3EDF7),
        surfaceContainerHigh: Color(hex: 0xECE6F0),
        onSurface: Color(hex: 0x1D1B20), onSurfaceVariant: Color(hex: 0x49454F),
        outline: Color(hex: 0x7A757F), outlineVariant: Color(hex: 0xCAC4D0),
        error: Color(hex: 0xB3261E)
    )

    static let dark = Palette(
        primary: Color(hex: 0xCFBDFE), onPrimary: Color(hex: 0x36265E),
        primaryContainer: Color(hex: 0x4D3D76), onPrimaryContainer: Color(hex: 0xE9DDFF),
        secondaryContainer: Color(hex: 0x2C4A3F), onSecondaryContainer: Color(hex: 0xD3EDE1),
        tertiaryContainer: Color(hex: 0x5E3B27), onTertiaryContainer: Color(hex: 0xFFDDCC),
        surface: Color(hex: 0x141218), surfaceBright: Color(hex: 0x3B383E),
        surfaceContainer: Color(hex: 0x211F26),
        surfaceContainerHigh: Color(hex: 0x2B2930),
        onSurface: Color(hex: 0xE6E0E9), onSurfaceVariant: Color(hex: 0xCAC4D0),
        outline: Color(hex: 0x948F99), outlineVariant: Color(hex: 0x49454F),
        error: Color(hex: 0xF2B8B5)
    )
}

extension EnvironmentValues {
    /// The palette for the current light/dark appearance.
    public var palette: Palette { Palette.resolve(colorScheme) }
}

/// Material 3 shape scale (corner radii).
public enum Corner {
    public static let extraSmall: CGFloat = 4
    public static let small: CGFloat = 8
    public static let medium: CGFloat = 12
    public static let large: CGFloat = 16
}

/// Material 3 type scale, on the system font.
extension Font {
    public static let m3TitleLarge = Font.system(size: 22)
    public static let m3TitleMedium = Font.system(size: 16, weight: .medium)
    public static let m3BodyLarge = Font.system(size: 16)
    public static let m3BodyMedium = Font.system(size: 14)
    public static let m3LabelLarge = Font.system(size: 14, weight: .medium)
}

/// The Me / Links / Answers switcher: a row of pills, the selected one filled with its tab's pastel.
public struct TabSelector: View {
    @Environment(\.palette) private var palette

    private let selection: SnippetTab
    private let onSelect: (SnippetTab) -> Void

    public init(selection: SnippetTab, onSelect: @escaping (SnippetTab) -> Void) {
        self.selection = selection
        self.onSelect = onSelect
    }

    public var body: some View {
        HStack(spacing: 8) {
            ForEach(SnippetTab.allCases) { tab in
                let isSelected = tab == selection
                Button {
                    onSelect(tab)
                } label: {
                    Text(tab.title)
                        .font(.m3LabelLarge)
                        .foregroundStyle(isSelected ? palette.onContainer(for: tab) : palette.onSurfaceVariant)
                        .frame(maxWidth: .infinity, minHeight: 36)
                        .background(isSelected ? palette.container(for: tab) : Color.clear, in: Capsule())
                        .overlay(Capsule().strokeBorder(isSelected ? Color.clear : palette.outlineVariant))
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
    }
}

extension Color {
    fileprivate init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
