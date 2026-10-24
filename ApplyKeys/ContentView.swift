import ApplyKeysCore
import SwiftUI

struct ContentView: View {
    let store: SnippetStore

    @State private var tab: SnippetTab = .me
    @State private var editing: EditTarget?
    @State private var showingSetup = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Tab", selection: $tab) {
                        ForEach(SnippetTab.allCases) { Text($0.title).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }

                Section {
                    ForEach(store.snippets(in: tab)) { snippet in
                        Button {
                            editing = .existing(snippet)
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(snippet.label).foregroundStyle(.primary)
                                Text(snippet.value).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                            }
                        }
                    }
                    .onDelete { offsets in
                        let ids = offsets.map { store.snippets(in: tab)[$0].id }
                        attempt { for id in ids { try store.delete(id) } }
                    }
                    .onMove { source, destination in
                        attempt { try store.move(in: tab, fromOffsets: source, toOffset: destination) }
                    }
                } footer: {
                    if store.snippets(in: tab).isEmpty {
                        Text("No snippets yet. Tap + to add one.")
                    }
                }
            }
            .navigationTitle("ApplyKeys")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Setup") { showingSetup = true }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    EditButton()
                    Button("Add", systemImage: "plus") { editing = .new(tab) }
                }
            }
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
