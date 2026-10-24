import SwiftUI

struct SetupView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Turn on the keyboard") {
                    Step(1, "Open Settings → General → Keyboard → Keyboards.")
                    Step(2, "Tap Add New Keyboard… and choose ApplyKeys.")
                    Step(3, "Tap ApplyKeys and turn on Allow Full Access.")
                }
                Section("Use it") {
                    Step(4, "In any application form, hold or tap 🌐 to switch to ApplyKeys.")
                    Step(5, "Pick a tab and tap a snippet to insert it. Tap 🌐 again to go back.")
                }
                Section {
                    Text("Full Access lets the keyboard read the snippets you save here. ApplyKeys has no network code: your details stay on this iPhone.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Section {
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            }
            .navigationTitle("Setup")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

private struct Step: View {
    let number: Int
    let text: String

    init(_ number: Int, _ text: String) {
        self.number = number
        self.text = text
    }

    var body: some View {
        Label {
            Text(text)
        } icon: {
            Text("\(number)").font(.headline)
        }
    }
}
