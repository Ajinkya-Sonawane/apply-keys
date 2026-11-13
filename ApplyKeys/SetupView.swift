import ApplyKeysCore
import SwiftUI

struct SetupView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.palette) private var palette

    var body: some View {
        VStack(spacing: 0) {
            SheetBar(title: "Setup", close: { dismiss() }) {}
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    card("Turn on the keyboard") {
                        Step(1, "Open Settings → General → Keyboard → Keyboards.")
                        Step(2, "Tap Add New Keyboard… and choose ApplyKeys.")
                        Step(3, "Tap ApplyKeys and turn on Allow Full Access.")
                    }
                    card("Use it") {
                        Step(4, "In any application form, hold or tap 🌐 to switch to ApplyKeys.")
                        Step(5, "Pick a tab and tap a snippet to insert it. Tap 🌐 again to go back.")
                    }
                    Text("Full Access lets the keyboard read the snippets you save here. ApplyKeys has no network code: your details stay on this iPhone.")
                        .font(.m3BodyMedium)
                        .foregroundStyle(palette.onSurfaceVariant)
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .buttonStyle(TonalButtonStyle())
                }
                .padding(16)
            }
        }
        .background(palette.surface.ignoresSafeArea())
    }

    private func card(_ title: String, @ViewBuilder steps: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.m3TitleMedium)
                .foregroundStyle(palette.onSurface)
            steps()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(palette.surfaceContainer, in: RoundedRectangle(cornerRadius: Corner.medium))
    }
}

private struct Step: View {
    @Environment(\.palette) private var palette

    let number: Int
    let text: String

    init(_ number: Int, _ text: String) {
        self.number = number
        self.text = text
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Text("\(number)")
                .font(.m3LabelLarge)
                .foregroundStyle(palette.onPrimaryContainer)
                .frame(width: 28, height: 28)
                .background(palette.primaryContainer, in: Circle())
            Text(text)
                .font(.m3BodyLarge)
                .foregroundStyle(palette.onSurface)
                .padding(.top, 4)
        }
    }
}
