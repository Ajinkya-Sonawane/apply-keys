import Foundation
import Observation

/// What the keyboard writes into; the extension wraps its text document proxy.
@MainActor
public protocol TextInserting: AnyObject {
    func insertText(_ text: String)
    func deleteBackward()
}

public enum PanelState: Equatable, Sendable {
    case needsFullAccess
    case ready(selectedTab: SnippetTab, snippets: [Snippet])

    public var selectedTab: SnippetTab? {
        if case let .ready(tab, _) = self { tab } else { nil }
    }

    public var snippets: [Snippet] {
        if case let .ready(_, snippets) = self { snippets } else { [] }
    }
}

/// Drives the snippet panel: what it shows and what each key does.
@MainActor
@Observable
public final class KeyboardController {
    public private(set) var state: PanelState = .needsFullAccess

    @ObservationIgnored private let store: SnippetStore
    @ObservationIgnored private weak var inserter: TextInserting?
    @ObservationIgnored private let hasFullAccess: () -> Bool
    @ObservationIgnored private var selectedTab: SnippetTab = .me

    public init(storage: SnippetStorage, inserter: TextInserting, hasFullAccess: @escaping () -> Bool = { true }) {
        self.store = SnippetStore(storage: storage)
        self.inserter = inserter
        self.hasFullAccess = hasFullAccess
    }

    /// Re-reads snippets; call whenever the keyboard appears so edits made in the app show up.
    public func reload() {
        guard hasFullAccess() else {
            state = .needsFullAccess
            return
        }
        do {
            try store.load()
        } catch {
            // Show an empty panel rather than crash the keyboard; the app surfaces the error.
        }
        refresh()
    }

    public func select(_ tab: SnippetTab) {
        selectedTab = tab
        refresh()
    }

    public func tap(_ snippet: Snippet) {
        inserter?.insertText(snippet.value)
    }

    public func backspace() { inserter?.deleteBackward() }
    public func space() { inserter?.insertText(" ") }
    public func returnKey() { inserter?.insertText("\n") }

    private func refresh() {
        guard hasFullAccess() else { return }
        state = .ready(selectedTab: selectedTab, snippets: store.snippets(in: selectedTab))
    }
}
