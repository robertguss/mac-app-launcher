// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "WorkspacePresets",
    platforms: [.macOS(.v14)],
    targets: [
        .target(name: "PresetsCore"),
        .executableTarget(name: "presets", dependencies: ["PresetsCore"]),
        .testTarget(name: "PresetsCoreTests", dependencies: ["PresetsCore"]),
    ]
)
