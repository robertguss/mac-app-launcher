import Foundation
import Testing
@testable import PresetsCore

struct PresetStoreTests {
    let store = PresetStore(directory: FileManager.default.temporaryDirectory
        .appendingPathComponent("presets-tests-\(UUID().uuidString)"))

    func preset(_ apps: [String]) -> Preset {
        Preset(
            name: "work",
            display: DisplayRef(uuid: "ABC", name: "Built-in", width: 1800, height: 1169),
            entries: apps.enumerated().map { index, app in
                Entry(bundleID: app, appName: app, appPath: "/Applications/\(app).app",
                      chromeProfile: app == "com.google.Chrome" ? ChromeProfile(directory: "Profile 5", label: "Robert (Work)") : nil,
                      frame: Rect(x: Double(index) * 600, y: 0, width: 600, height: 584))
            }
        )
    }

    @Test func savedPresetLoadsBackUnchanged() throws {
        let saved = preset(["notion.id", "com.google.Chrome"])
        try store.save(saved)
        #expect(try store.load("work") == saved)
    }

    @Test func savingSameNameOverwrites() throws {
        try store.save(preset(["notion.id", "com.google.Chrome", "com.github.wez.wezterm"]))
        let second = preset(["dev.ampcode.amp"])
        try store.save(second)
        #expect(try store.load("work") == second)
    }
}
