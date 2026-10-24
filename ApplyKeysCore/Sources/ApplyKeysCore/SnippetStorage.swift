import Foundation

/// Where the encoded snippet list is kept. `read` returns nil when nothing has been saved yet.
public protocol SnippetStorage {
    func read() throws -> Data?
    func write(_ data: Data) throws
}

/// A JSON file on disk — in the app, inside the App Group container shared with the keyboard.
public struct FileStorage: SnippetStorage {
    public let url: URL

    public init(url: URL) {
        self.url = url
    }

    /// Storage in the shared App Group container, or nil if the container isn't reachable
    /// (e.g. the keyboard doesn't have Full Access).
    public static func appGroup(_ identifier: String) -> FileStorage? {
        guard let container = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: identifier)
        else { return nil }
        return FileStorage(url: container.appendingPathComponent("snippets.json"))
    }

    public func read() throws -> Data? {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return try Data(contentsOf: url)
    }

    public func write(_ data: Data) throws {
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: url, options: .atomic)
    }
}

/// Storage held in memory; for tests and previews.
public final class InMemoryStorage: SnippetStorage {
    public private(set) var data: Data?

    public init(data: Data? = nil) {
        self.data = data
    }

    public func read() throws -> Data? { data }

    public func write(_ data: Data) throws { self.data = data }
}
