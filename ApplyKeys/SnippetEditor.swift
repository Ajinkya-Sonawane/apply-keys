import ApplyKeysCore
import SwiftUI

struct SnippetEditor: View {
    let store: SnippetStore
    let target: EditTarget

    @Environment(\.dismiss) private var dismiss
    @Environment(\.palette) private var palette
    @State private var label: String
    @State private var value: String
    @State private var hint = "The text this key types"
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
        VStack(spacing: 0) {
            SheetBar(title: title, close: { dismiss() }) {
                Button("Save", action: save).buttonStyle(FilledButtonStyle())
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    OutlinedField(label: "Label (shown on the key)", placeholder: "e.g. GitHub, Visa status", text: $label)
                    if !suggestions.isEmpty {
                        suggestionChips
                    }
                    OutlinedField(label: "Text to insert", placeholder: hint, text: $value, multiline: true)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    if let error {
                        Text(error).font(.m3BodyMedium).foregroundStyle(palette.error)
                    }
                }
                .padding(16)
            }
        }
        .background(palette.surface.ignoresSafeArea())
        .tint(palette.primary)
    }

    private var title: String {
        switch target {
        case let .new(tab): "New \(tab.title) snippet"
        case .existing: "Edit snippet"
        }
    }

    // Offered only for new snippets: fields applications commonly ask for that aren't saved yet.
    private var suggestions: [SnippetSuggestion] {
        if case let .new(tab) = target { store.suggestions(for: tab) } else { [] }
    }

    private var suggestionChips: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Commonly asked")
                .font(.m3LabelLarge)
                .foregroundStyle(palette.onSurfaceVariant)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(suggestions) { suggestion in
                        let isChosen = suggestion.label == label
                        Button {
                            label = suggestion.label
                            hint = suggestion.hint
                        } label: {
                            Text(suggestion.label)
                                .font(.m3LabelLarge)
                                .foregroundStyle(isChosen ? palette.onSecondaryContainer : palette.onSurfaceVariant)
                                .padding(.horizontal, 16)
                                .frame(height: 32)
                                .background(
                                    isChosen ? palette.secondaryContainer : Color.clear,
                                    in: RoundedRectangle(cornerRadius: Corner.small)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: Corner.small)
                                        .strokeBorder(isChosen ? Color.clear : palette.outlineVariant)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.horizontal, -16)
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
