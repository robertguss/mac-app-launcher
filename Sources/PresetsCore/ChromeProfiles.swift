import Foundation

public struct ChromeProfiles: Sendable {
    public static let bundleID = "com.google.Chrome"
    private static let titleMarker = " - Google Chrome - "

    private let namesByDirectory: [String: String]

    public init(localState: Data) {
        let root = (try? JSONSerialization.jsonObject(with: localState)) as? [String: Any]
        let cache = (root?["profile"] as? [String: Any])?["info_cache"] as? [String: [String: Any]] ?? [:]
        namesByDirectory = cache.compactMapValues { $0["name"] as? String }
    }

    public static func installed() -> ChromeProfiles {
        let path = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/Google/Chrome/Local State")
        return ChromeProfiles(localState: (try? Data(contentsOf: path)) ?? Data())
    }

    public func profile(fromTitle title: String) -> ChromeProfile? {
        guard let marker = title.range(of: Self.titleMarker, options: .backwards) else { return nil }
        let label = String(title[marker.upperBound...])
        guard !label.isEmpty else { return nil }
        let candidates = [label, Self.parenthesized(label)].compactMap { $0 }
        let directory = namesByDirectory
            .filter { candidates.contains($0.value) }
            .map(\.key)
            .sorted()
            .first
        return ChromeProfile(directory: directory, label: label)
    }

    private static func parenthesized(_ label: String) -> String? {
        guard label.hasSuffix(")"), let open = label.range(of: "(", options: .backwards) else { return nil }
        return String(label[open.upperBound..<label.index(before: label.endIndex)])
    }
}
