import ApplyKeysCore
import SwiftUI

struct SnippetEditor: View {
    let store: SnippetStore
    let target: EditTarget

    @Environment(\.dismiss) private var dismiss
    @State private var label: String
    @State private var value: String
    @State private var error: String?

    init(store: SnippetStore, target: EditTarget) {
        self.store = store
        self.target = target
        switch target {
        case .new:
            _label = State(initialValue: "")
            _value = State(initialValue: "")
        case let .existing(snippet):
            _label = State(initialValue: snippet.label)
            _value = State(initialValue: snippet.value)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Label (shown on the key)") {
                    TextField("e.g. GitHub, Visa status", text: $label)
                }
                Section("Text to insert") {
                    TextField("Value", text: $value, axis: .vertical)
                        .lineLimit(3...12)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                if let error {
                    Text(error).foregroundStyle(.red)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                }
            }
        }
    }

    private var title: String {
        switch target {
        case let .new(tab): "New \(tab.title) snippet"
        case .existing: "Edit snippet"
        }
    }

    private func save() {
        do {
            switch target {
            case let .new(tab): try store.add(to: tab, label: label, value: value)
            case let .existing(snippet): try store.update(snippet.id, label: label, value: value)
            }
            dismiss()
        } catch SnippetError.emptyLabel {
            error = "Give the snippet a label."
        } catch SnippetError.emptyValue {
            error = "Enter the text to insert."
        } catch {
            self.error = error.localizedDescription
        }
    }
}
