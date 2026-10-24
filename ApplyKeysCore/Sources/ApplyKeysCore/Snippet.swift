import Foundation

/// The fixed groups snippets are organised into, in panel order.
public enum SnippetTab: String, Codable, CaseIterable, Identifiable, Sendable {
    case me, links, answers

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .me: "Me"
        case .links: "Links"
        case .answers: "Answers"
        }
    }
}

/// A piece of saved text, shown in the keyboard as a button with `label` and inserted as `value`.
public struct Snippet: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var tab: SnippetTab
    public var label: String
    public var value: String

    public init(id: UUID = UUID(), tab: SnippetTab, label: String, value: String) {
        self.id = id
        self.tab = tab
        self.label = label
        self.value = value
    }
}

public enum SnippetError: Error, Equatable {
    case emptyLabel
    case emptyValue
    case notFound
}
