import ApplyKeysCore
import SwiftUI

/// Header for a sheet: close button, title, and an optional trailing action.
struct SheetBar<Trailing: View>: View {
    @Environment(\.palette) private var palette

    let title: String
    let close: () -> Void
    @ViewBuilder let trailing: Trailing

    var body: some View {
        HStack(spacing: 4) {
            Button("Close", systemImage: "xmark", action: close)
                .labelStyle(.iconOnly)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(palette.onSurfaceVariant)
                .frame(width: 48, height: 48)
            Text(title)
                .font(.m3TitleLarge)
                .foregroundStyle(palette.onSurface)
                .lineLimit(1)
            Spacer()
            trailing
        }
        .padding(.leading, 4)
        .padding(.trailing, 16)
        .frame(height: 64)
    }
}

/// Material 3 filled button: the one primary action on a screen.
struct FilledButtonStyle: ButtonStyle {
    @Environment(\.palette) private var palette

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.m3LabelLarge)
            .foregroundStyle(palette.onPrimary)
            .padding(.horizontal, 24)
            .frame(height: 40)
            .background(palette.primary, in: Capsule())
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

/// Material 3 filled tonal button: a secondary action.
struct TonalButtonStyle: ButtonStyle {
    @Environment(\.palette) private var palette

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.m3LabelLarge)
            .foregroundStyle(palette.onSecondaryContainer)
            .padding(.horizontal, 24)
            .frame(height: 40)
            .background(palette.secondaryContainer, in: Capsule())
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

/// Material 3 outlined text field with its label above.
struct OutlinedField: View {
    @Environment(\.palette) private var palette
    @FocusState private var isFocused: Bool

    let label: String
    let placeholder: String
    @Binding var text: String
    var multiline = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.m3LabelLarge)
                .foregroundStyle(isFocused ? palette.primary : palette.onSurfaceVariant)
            TextField(placeholder, text: $text, axis: multiline ? .vertical : .horizontal)
                .lineLimit(multiline ? 3...12 : 1...1)
                .font(.m3BodyLarge)
                .foregroundStyle(palette.onSurface)
                .focused($isFocused)
                .padding(16)
                .overlay(
                    RoundedRectangle(cornerRadius: Corner.extraSmall)
                        .strokeBorder(isFocused ? palette.primary : palette.outline, lineWidth: isFocused ? 2 : 1)
                )
                .contentShape(Rectangle())
                .onTapGesture { isFocused = true }
        }
    }
}
