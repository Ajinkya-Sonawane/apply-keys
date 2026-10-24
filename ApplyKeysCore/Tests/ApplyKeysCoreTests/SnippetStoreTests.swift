import Foundation
import Testing
@testable import ApplyKeysCore

@MainActor
struct SnippetStoreTests {
    @Test func seedsExamplesOnFirstLoad() throws {
        let store = SnippetStore(storage: InMemoryStorage())
        try store.load()

        #expect(!store.snippets(in: .me).isEmpty)
        #expect(store.snippets(in: .links).map(\.label).contains("LinkedIn"))
        #expect(!store.snippets(in: .answers).isEmpty)
    }

    @Test func doesNotReseedWhenUserDeletedEverything() throws {
        let storage = InMemoryStorage()
        let store = SnippetStore(storage: storage)
        try store.load()
        for snippet in store.all { try store.delete(snippet.id) }

        let reopened = SnippetStore(storage: storage)
        try reopened.load()

        #expect(reopened.all.isEmpty)
    }

    @Test func addedSnippetAppearsAtEndOfItsTab() throws {
        let store = try emptyStore()
        try store.add(to: .links, label: "GitHub", value: "https://github.com/me")
        try store.add(to: .links, label: "Portfolio", value: "https://me.dev")

        #expect(store.snippets(in: .links).map(\.label) == ["GitHub", "Portfolio"])
        #expect(store.snippets(in: .me).isEmpty)
    }

    @Test func rejectsBlankLabelOrValue() throws {
        let store = try emptyStore()

        #expect(throws: SnippetError.emptyLabel) {
            try store.add(to: .me, label: "  ", value: "x")
        }
        #expect(throws: SnippetError.emptyValue) {
            try store.add(to: .me, label: "Email", value: "\n")
        }
        #expect(store.all.isEmpty)
    }

    @Test func keepsValueExactlyAsTyped() throws {
        let store = try emptyStore()
        let answer = "Line one.\n\nLine two "
        try store.add(to: .answers, label: " Why leaving ", value: answer)

        let saved = try #require(store.snippets(in: .answers).first)
        #expect(saved.label == "Why leaving")
        #expect(saved.value == answer)
    }

    @Test func updatesLabelAndValue() throws {
        let store = try emptyStore()
        let snippet = try store.add(to: .me, label: "Phone", value: "123")

        try store.update(snippet.id, label: "Mobile", value: "456")

        #expect(store.snippets(in: .me) == [Snippet(id: snippet.id, tab: .me, label: "Mobile", value: "456")])
    }

    @Test func updateRejectsBlankAndUnknown() throws {
        let store = try emptyStore()
        let snippet = try store.add(to: .me, label: "Phone", value: "123")

        #expect(throws: SnippetError.emptyValue) {
            try store.update(snippet.id, label: "Phone", value: " ")
        }
        #expect(throws: SnippetError.notFound) {
            try store.update(UUID(), label: "a", value: "b")
        }
        #expect(store.snippets(in: .me).first?.value == "123")
    }

    @Test func deletesSnippet() throws {
        let store = try emptyStore()
        let a = try store.add(to: .me, label: "A", value: "1")
        try store.add(to: .me, label: "B", value: "2")

        try store.delete(a.id)

        #expect(store.snippets(in: .me).map(\.label) == ["B"])
    }

    @Test func reordersWithinTabOnly() throws {
        let store = try emptyStore()
        for label in ["A", "B", "C"] { try store.add(to: .links, label: label, value: label) }
        try store.add(to: .me, label: "Email", value: "e")

        // Same semantics as SwiftUI's onMove: move "C" to the front.
        try store.move(in: .links, fromOffsets: [2], toOffset: 0)
        #expect(store.snippets(in: .links).map(\.label) == ["C", "A", "B"])

        // Move "C" to the end.
        try store.move(in: .links, fromOffsets: [0], toOffset: 3)
        #expect(store.snippets(in: .links).map(\.label) == ["A", "B", "C"])

        #expect(store.snippets(in: .me).map(\.label) == ["Email"])
    }

    @Test func changesSurviveReopening() throws {
        let storage = InMemoryStorage()
        let store = SnippetStore(storage: storage)
        try store.load()
        for snippet in store.all { try store.delete(snippet.id) }
        try store.add(to: .answers, label: "Visa", value: "No sponsorship needed")
        try store.add(to: .answers, label: "Notice", value: "Two weeks")
        try store.move(in: .answers, fromOffsets: [1], toOffset: 0)

        let reopened = SnippetStore(storage: storage)
        try reopened.load()

        #expect(reopened.snippets(in: .answers).map(\.label) == ["Notice", "Visa"])
    }

    @Test func corruptDataIsReportedNotOverwritten() throws {
        let storage = InMemoryStorage(data: Data("not json".utf8))
        let store = SnippetStore(storage: storage)

        #expect(throws: (any Error).self) { try store.load() }
        #expect(storage.data == Data("not json".utf8))
    }

    @Test func fileStorageRoundTrips() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("snippets.json")
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }

        let store = SnippetStore(storage: FileStorage(url: url))
        try store.load()
        try store.add(to: .links, label: "Site", value: "https://me.dev")

        let reopened = SnippetStore(storage: FileStorage(url: url))
        try reopened.load()

        #expect(reopened.all == store.all)
    }

    private func emptyStore() throws -> SnippetStore {
        let store = SnippetStore(storage: InMemoryStorage(data: Data("[]".utf8)))
        try store.load()
        return store
    }
}
