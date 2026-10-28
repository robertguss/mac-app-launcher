import Foundation

public struct PresetStore: Sendable {
    public let directory: URL

    public init(directory: URL) {
        self.directory = directory
    }

    public static func standard() -> PresetStore {
        if let override = ProcessInfo.processInfo.environment["PRESETS_DIR"], !override.isEmpty {
            return PresetStore(directory: URL(fileURLWithPath: override))
        }
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return PresetStore(directory: support.appendingPathComponent("WorkspacePresets"))
    }

    private func url(for name: String) -> URL {
        directory.appendingPathComponent("\(name).json")
    }

    public func save(_ preset: Preset) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(preset).write(to: url(for: preset.name), options: .atomic)
    }

    public func load(_ name: String) throws -> Preset {
        let file = url(for: name)
        guard FileManager.default.fileExists(atPath: file.path) else {
            throw PresetError("No preset named \"\(name)\" in \(directory.path)")
        }
        return try JSONDecoder().decode(Preset.self, from: Data(contentsOf: file))
    }
}

public struct PresetError: Error, CustomStringConvertible {
    public let description: String

    public init(_ description: String) {
        self.description = description
    }
}
