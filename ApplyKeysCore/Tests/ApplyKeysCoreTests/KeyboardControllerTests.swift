import Foundation
import Testing
@testable import ApplyKeysCore

@MainActor
final class RecordingInserter: TextInserting {
    var inserted: [String] = []
    var deletes = 0
    func insertText(_ text: String) { inserted.append(text) }
    func deleteBackward() { deletes += 1 }
}

@MainActor
struct KeyboardControllerTests {
    @Test func withoutFullAccessAsksToEnableIt() {
        let controller = KeyboardController(
            storage: InMemoryStorage(), inserter: RecordingInserter(), hasFullAccess: { false })
        controller.reload()

        #expect(controller.state == .needsFullAccess)
    }

    @Test func showsMeTabFirst() throws {
        let storage = try storage(with: [
            (.links, "GitHub", "https://github.com/me"),
            (.me, "Email", "me@example.com"),
        ])
        let controller = KeyboardController(storage: storage, inserter: RecordingInserter())
        controller.reload()

        guard case let .ready(tab, snippets) = controller.state else {
            Issue.record("expected ready, got \(controller.state)"); return
        }
        #expect(tab == .me)
        #expect(snippets.map(\.label) == ["Email"])
    }

    @Test func switchingTabShowsThatTabsSnippetsInOrder() throws {
        let storage = try storage(with: [
            (.links, "LinkedIn", "https://linkedin.com/in/me"),
            (.links, "GitHub", "https://github.com/me"),
        ])
        let controller = KeyboardController(storage: storage, inserter: RecordingInserter())
        controller.reload()

        controller.select(.links)

        #expect(controller.state.snippets.map(\.label) == ["LinkedIn", "GitHub"])
        #expect(controller.state.selectedTab == .links)
    }

    @Test func tappingSnippetInsertsValueExactly() throws {
        let answer = "I'm looking for a team that ships.\nHappy to relocate."
        let storage = try storage(with: [
            (.links, "GitHub", "https://github.com/me"),
            (.answers, "Why", answer),
        ])
        let inserter = RecordingInserter()
        let controller = KeyboardController(storage: storage, inserter: inserter)
        controller.reload()

        controller.select(.links)
        controller.tap(controller.state.snippets[0])
        controller.select(.answers)
        controller.tap(controller.state.snippets[0])

        #expect(inserter.inserted == ["https://github.com/me", answer])
    }

    @Test func editKeysWorkEvenWithoutFullAccess() {
        let inserter = RecordingInserter()
        let controller = KeyboardController(
            storage: InMemoryStorage(), inserter: inserter, hasFullAccess: { false })
        controller.reload()

        controller.space()
        controller.returnKey()
        controller.backspace()

        #expect(inserter.inserted == [" ", "\n"])
        #expect(inserter.deletes == 1)
    }

    @Test func reloadPicksUpEditsAndKeepsSelectedTab() throws {
        let storage = try storage(with: [(.links, "GitHub", "https://github.com/me")])
        let controller = KeyboardController(storage: storage, inserter: RecordingInserter())
        controller.reload()
        controller.select(.links)

        // The companion app edits the shared data while the keyboard is hidden.
        let app = SnippetStore(storage: storage)
        try app.load()
        try app.add(to: .links, label: "Portfolio", value: "https://me.dev")
        controller.reload()

        #expect(controller.state.selectedTab == .links)
        #expect(controller.state.snippets.map(\.label) == ["GitHub", "Portfolio"])
    }

    @Test func unreadableDataShowsEmptyPanel() {
        let controller = KeyboardController(
            storage: InMemoryStorage(data: Data("garbage".utf8)), inserter: RecordingInserter())
        controller.reload()

        #expect(controller.state == .ready(selectedTab: .me, snippets: []))
    }

    private func storage(with items: [(SnippetTab, String, String)]) throws -> InMemoryStorage {
        let storage = InMemoryStorage(data: Data("[]".utf8))
        let store = SnippetStore(storage: storage)
        try store.load()
        for (tab, label, value) in items { try store.add(to: tab, label: label, value: value) }
        return storage
    }
}
