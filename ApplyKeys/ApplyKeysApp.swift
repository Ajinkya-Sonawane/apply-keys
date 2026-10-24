import ApplyKeysCore
import SwiftUI

@main
struct ApplyKeysApp: App {
    @State private var store = SnippetStore(storage: AppGroup.storage ?? InMemoryStorage())
    @State private var loadError: String?

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
                .task {
                    do {
                        try store.load()
                    } catch {
                        loadError = "Couldn't read saved snippets: \(error.localizedDescription)"
                    }
                }
                .alert("Something went wrong", isPresented: .constant(loadError != nil)) {
                    Button("OK") { loadError = nil }
                } message: {
                    Text(loadError ?? "")
                }
        }
    }
}
