public struct WindowIdentity: Equatable, Sendable {
    public var bundleID: String
    public var profile: ChromeProfile?

    public init(bundleID: String, profile: ChromeProfile?) {
        self.bundleID = bundleID
        self.profile = profile
    }

    public static func == (lhs: WindowIdentity, rhs: WindowIdentity) -> Bool {
        lhs.bundleID == rhs.bundleID && lhs.profileKey == rhs.profileKey
    }

    private var profileKey: String? {
        profile.map { $0.directory ?? $0.label }
    }
}

public struct LiveWindow<Handle> {
    public var handle: Handle
    public var identity: WindowIdentity

    public init(handle: Handle, identity: WindowIdentity) {
        self.handle = handle
        self.identity = identity
    }
}

public func assign<Handle>(entries: [Entry], to windows: [LiveWindow<Handle>]) -> [Int: Handle] {
    var used = Set<Int>()
    var result: [Int: Handle] = [:]
    for (entryIndex, entry) in entries.enumerated() {
        guard let windowIndex = windows.indices.first(where: { !used.contains($0) && windows[$0].identity == entry.identity }) else { continue }
        used.insert(windowIndex)
        result[entryIndex] = windows[windowIndex].handle
    }
    return result
}
