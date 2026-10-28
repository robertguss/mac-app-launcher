public struct Point: Codable, Equatable, Sendable {
    public var x: Double
    public var y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

public struct Rect: Codable, Equatable, Sendable {
    public var x: Double
    public var y: Double
    public var width: Double
    public var height: Double

    public init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    public func offset(by origin: Point) -> Rect {
        Rect(x: x + origin.x, y: y + origin.y, width: width, height: height)
    }

    public func isClose(to other: Rect) -> Bool {
        abs(x - other.x) <= 2 && abs(y - other.y) <= 2 && abs(width - other.width) <= 2 && abs(height - other.height) <= 2
    }
}

public struct ChromeProfile: Codable, Equatable, Sendable {
    public var directory: String?
    public var label: String

    public init(directory: String?, label: String) {
        self.directory = directory
        self.label = label
    }
}

public struct DisplayRef: Codable, Equatable, Sendable {
    public var uuid: String
    public var name: String
    public var width: Double
    public var height: Double

    public init(uuid: String, name: String, width: Double, height: Double) {
        self.uuid = uuid
        self.name = name
        self.width = width
        self.height = height
    }
}

public struct Entry: Codable, Equatable, Sendable {
    public var bundleID: String
    public var appName: String
    public var appPath: String
    public var chromeProfile: ChromeProfile?
    public var frame: Rect

    public init(bundleID: String, appName: String, appPath: String, chromeProfile: ChromeProfile?, frame: Rect) {
        self.bundleID = bundleID
        self.appName = appName
        self.appPath = appPath
        self.chromeProfile = chromeProfile
        self.frame = frame
    }

    public var identity: WindowIdentity {
        WindowIdentity(bundleID: bundleID, profile: chromeProfile)
    }
}

public struct Preset: Codable, Equatable, Sendable {
    public var name: String
    public var display: DisplayRef
    public var entries: [Entry]

    public init(name: String, display: DisplayRef, entries: [Entry]) {
        self.name = name
        self.display = display
        self.entries = entries
    }
}
