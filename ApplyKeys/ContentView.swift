import ApplyKeysCore
import SwiftUI

struct ContentView: View {
    let store: SnippetStore

    @Environment(\.palette) private var palette
    @State private var tab: SnippetTab = .me
    @State private var editMode: EditMode = .inactive
    @State private var editing: EditTarget?
    @State private var showingSetup = false
    @State private var error: String?

    var body: some View {
        VStack(spacing: 0) {
            topBar
            TabSelector(selection: tab) { tab = $0 }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            list
        }
        .background(palette.surface.ignoresSafeArea())
        .overlay(alignment: .bottomTrailing) { addButton }
        .tint(palette.primary)
        .sheet(item: $editing) { target in
            SnippetEditor(store: store, target: target)
        }
        .sheet(isPresented: $showingSetup) {
            SetupView()
        }
        .alert("Something went wrong", isPresented: .constant(error != nil)) {
            Button("OK") { error = nil }
        } message: {
            Text(error ?? "")
        }
    }

    private var topBar: some View {
        HStack(spacing: 4) {
            Text("ApplyKeys")
                .font(.m3TitleLarge)
                .foregroundStyle(palette.onSurface)
            Spacer()
            Button(editMode.isEditing ? "Done" : "Reorder") {
                withAnimation { editMode = editMode.isEditing ? .inactive : .active }
            }
            .font(.m3LabelLarge)
            .padding(.horizontal, 12)
            .frame(height: 40)
            Button("Setup", systemImage: "questionmark.circle") { showingSetup = true }
                .labelStyle(.iconOnly)
                .font(.system(size: 22))
                .foregroundStyle(palette.onSurfaceVariant)
                .frame(width: 40, height: 40)
        }
        .padding(.leading, 16)
        .padding(.trailing, 8)
        .frame(height: 64)
    }

    private var list: some View {
        List {
            ForEach(store.snippets(in: tab)) { snippet in
                Button {
                    editing = .existing(snippet)
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(snippet.label)
                            .font(.m3TitleMedium)
                            .foregroundStyle(palette.onSurface)
                        Text(snippet.value)
                            .font(.m3BodyMedium)
                            .foregroundStyle(palette.onSurfaceVariant)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .listRowInsets(EdgeInsets(top: 16, leading: 32, bottom: 16, trailing: 32))
                .listRowSeparator(.hidden)
                .listRowBackground(
                    RoundedRectangle(cornerRadius: Corner.medium)
                        .fill(palette.surfaceContainer)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 4)
                )
            }
            .onDelete { offsets in
                let ids = offsets.map { store.snippets(in: tab)[$0].id }
                attempt { for id in ids { try store.delete(id) } }
            }
            .onMove { source, destination in
                attempt { try store.move(in: tab, fromOffsets: source, toOffset: destination) }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .contentMargins(.bottom, 88, for: .scrollContent)
        .environment(\.editMode, $editMode)
        .overlay {
            if store.snippets(in: tab).isEmpty {
                VStack(spacing: 4) {
                    Text("No \(tab.title) snippets yet")
                        .font(.m3TitleMedium)
                        .foregroundStyle(palette.onSurface)
                    Text("Tap + to add one.")
                        .font(.m3BodyMedium)
                        .foregroundStyle(palette.onSurfaceVariant)
                }
            }
        }
    }

    // Material 3 floating action button.
    private var addButton: some View {
        Button {
            editing = .new(tab)
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 24))
                .foregroundStyle(palette.onPrimaryContainer)
                .frame(width: 56, height: 56)
                .background(palette.primaryContainer, in: RoundedRectangle(cornerRadius: Corner.large))
                .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
        }
        .padding(16)
        .accessibilityLabel("Add snippet")
    }

    private func attempt(_ change: () throws -> Void) {
        do { try change() } catch { self.error = error.localizedDescription }
    }
}

enum EditTarget: Identifiable {
    case new(SnippetTab)
    case existing(Snippet)

    var id: String {
        switch self {
        case let .new(tab): "new-\(tab.rawValue)"
        case let .existing(snippet): snippet.id.uuidString
        }
    }
}
