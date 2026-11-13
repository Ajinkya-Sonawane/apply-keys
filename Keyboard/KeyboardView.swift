import ApplyKeysCore
import SwiftUI
import UIKit

struct KeyboardView: View {
    let controller: KeyboardController
    let showsNextKeyboardKey: Bool
    let nextKeyboard: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        VStack(spacing: 8) {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            bottomRow
        }
        .padding(8)
    }

    @ViewBuilder
    private var content: some View {
        switch controller.state {
        case .needsFullAccess:
            Message(
                "Turn on Full Access",
                detail: "Settings → General → Keyboard → Keyboards → ApplyKeys → Allow Full Access. ApplyKeys needs it to read the snippets you save in the app; nothing leaves your phone."
            )
        case let .ready(selectedTab, snippets):
            VStack(spacing: 8) {
                TabSelector(selection: selectedTab) { controller.select($0) }

                if snippets.isEmpty {
                    Message("No \(selectedTab.title) snippets yet", detail: "Add some in the ApplyKeys app.")
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
                            ForEach(snippets) { snippet in
                                Button {
                                    controller.tap(snippet)
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                } label: {
                                    Text(snippet.label)
                                        .lineLimit(1)
                                        .padding(.horizontal, 8)
                                        .frame(maxWidth: .infinity, minHeight: 44)
                                }
                                .buttonStyle(KeyStyle(
                                    fill: palette.container(for: selectedTab),
                                    content: palette.onContainer(for: selectedTab)
                                ))
                            }
                        }
                    }
                }
            }
        }
    }

    private var bottomRow: some View {
        HStack(spacing: 8) {
            if showsNextKeyboardKey {
                key(systemImage: "globe", label: "Next keyboard", action: nextKeyboard).frame(width: 48)
            }
            key(title: "space", action: controller.space)
            key(systemImage: "delete.left", label: "Delete", action: controller.backspace).frame(width: 56)
            key(systemImage: "return", label: "Return", action: controller.returnKey).frame(width: 56)
        }
        .frame(height: 44)
    }

    private func key(
        title: String? = nil, systemImage: String? = nil, label: String? = nil, action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Group {
                if let systemImage { Image(systemName: systemImage) } else { Text(title ?? "") }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(KeyStyle(fill: palette.surfaceBright, content: palette.onSurface))
        .accessibilityLabel(label ?? title ?? "")
    }
}

private struct Message: View {
    @Environment(\.palette) private var palette

    let title: String
    let detail: String

    init(_ title: String, detail: String) {
        self.title = title
        self.detail = detail
    }

    var body: some View {
        VStack(spacing: 4) {
            Text(title).font(.m3TitleMedium).foregroundStyle(palette.onSurface)
            Text(detail).font(.m3BodyMedium).foregroundStyle(palette.onSurfaceVariant)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// A flat tonal key: pastel fill, no shadow, dims while pressed.
private struct KeyStyle: ButtonStyle {
    let fill: Color
    let content: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.m3LabelLarge)
            .foregroundStyle(content)
            .background(fill, in: RoundedRectangle(cornerRadius: Corner.medium))
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}
