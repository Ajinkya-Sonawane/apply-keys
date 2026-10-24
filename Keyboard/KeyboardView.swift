import ApplyKeysCore
import SwiftUI
import UIKit

struct KeyboardView: View {
    let controller: KeyboardController
    let showsNextKeyboardKey: Bool
    let nextKeyboard: () -> Void

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
                Picker("Tab", selection: Binding(get: { selectedTab }, set: { controller.select($0) })) {
                    ForEach(SnippetTab.allCases) { Text($0.title).tag($0) }
                }
                .pickerStyle(.segmented)

                if snippets.isEmpty {
                    Message("No \(selectedTab.title) snippets yet", detail: "Add some in the ApplyKeys app.")
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 6)], spacing: 6) {
                            ForEach(snippets) { snippet in
                                Button {
                                    controller.tap(snippet)
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                } label: {
                                    Text(snippet.label)
                                        .lineLimit(1)
                                        .frame(maxWidth: .infinity, minHeight: 40)
                                }
                                .buttonStyle(KeyStyle())
                            }
                        }
                    }
                }
            }
        }
    }

    private var bottomRow: some View {
        HStack(spacing: 6) {
            if showsNextKeyboardKey {
                key(systemImage: "globe", action: nextKeyboard).frame(width: 48)
            }
            key(title: "space", action: controller.space)
            key(systemImage: "delete.left", action: controller.backspace).frame(width: 56)
            key(systemImage: "return", action: controller.returnKey).frame(width: 56)
        }
        .frame(height: 42)
    }

    private func key(title: String? = nil, systemImage: String? = nil, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Group {
                if let systemImage { Image(systemName: systemImage) } else { Text(title ?? "") }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(KeyStyle())
    }
}

private struct Message: View {
    let title: String
    let detail: String

    init(_ title: String, detail: String) {
        self.title = title
        self.detail = detail
    }

    var body: some View {
        VStack(spacing: 6) {
            Text(title).font(.headline)
            Text(detail).font(.footnote).foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct KeyStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.callout)
            .foregroundStyle(.primary)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(configuration.isPressed ? Color(.systemGray4) : Color(.secondarySystemBackground))
            )
            .shadow(color: .black.opacity(0.15), radius: 0, y: 1)
    }
}
