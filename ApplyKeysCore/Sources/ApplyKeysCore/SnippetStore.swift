import Foundation
import Observation

/// The single place snippets are read and changed. Order within a tab is the order shown in the keyboard.
@MainActor
@Observable
public final class SnippetStore {
    public private(set) var all: [Snippet] = []

    @ObservationIgnored private let storage: SnippetStorage

    public init(storage: SnippetStorage) {
        self.storage = storage
    }

    /// Reads saved snippets, seeding examples the very first time. Unreadable data throws and is left untouched.
    public func load() throws {
        if let data = try storage.read() {
            all = try JSONDecoder().decode([Snippet].self, from: data)
        } else {
            all = Self.examples
            try save()
        }
    }

    public func snippets(in tab: SnippetTab) -> [Snippet] {
        all.filter { $0.tab == tab }
    }

    @discardableResult
    public func add(to tab: SnippetTab, label: String, value: String) throws -> Snippet {
        let snippet = Snippet(tab: tab, label: try Self.validLabel(label), value: try Self.validValue(value))
        all.append(snippet)
        try save()
        return snippet
    }

    public func update(_ id: UUID, label: String, value: String) throws {
        guard let index = all.firstIndex(where: { $0.id == id }) else { throw SnippetError.notFound }
        let label = try Self.validLabel(label)
        let value = try Self.validValue(value)
        all[index].label = label
        all[index].value = value
        try save()
    }

    public func delete(_ id: UUID) throws {
        guard let index = all.firstIndex(where: { $0.id == id }) else { throw SnippetError.notFound }
        all.remove(at: index)
        try save()
    }

    /// Reorders one tab using the same offsets SwiftUI's `onMove` provides.
    public func move(in tab: SnippetTab, fromOffsets source: IndexSet, toOffset destination: Int) throws {
        var items = snippets(in: tab)
        let moving = source.map { items[$0] }
        let insertAt = destination - source.count(in: 0..<destination)
        for offset in source.reversed() { items.remove(at: offset) }
        items.insert(contentsOf: moving, at: insertAt)

        all = SnippetTab.allCases.flatMap { $0 == tab ? items : snippets(in: $0) }
        try save()
    }

    private func save() throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        try storage.write(try encoder.encode(all))
    }

    private static func validLabel(_ label: String) throws -> String {
        let trimmed = label.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw SnippetError.emptyLabel }
        return trimmed
    }

    // Values are kept exactly as typed; only all-whitespace is rejected.
    private static func validValue(_ value: String) throws -> String {
        guard !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw SnippetError.emptyValue }
        return value
    }

    static let examples: [Snippet] = [
        Snippet(tab: .me, label: "Email", value: "you@example.com"),
        Snippet(tab: .me, label: "Phone", value: "+1 555 555 5555"),
        Snippet(tab: .links, label: "LinkedIn", value: "https://www.linkedin.com/in/your-handle"),
        Snippet(tab: .links, label: "GitHub", value: "https://github.com/your-handle"),
        Snippet(
            tab: .answers, label: "Why this role",
            value: "Edit me in ApplyKeys: a short, reusable answer to a common application question."),
    ]
}
