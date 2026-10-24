/// The App Group shared by the companion app and the keyboard extension.
/// Must match both targets' entitlements.
public enum AppGroup {
    public static let identifier = "group.com.ajinkyasonawane.ApplyKeys"

    @MainActor
    public static var storage: SnippetStorage? { FileStorage.appGroup(identifier) }
}
