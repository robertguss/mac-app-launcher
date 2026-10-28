import AppKit
import PresetsCore

func save(name: String, store: PresetStore) throws {
    let displays = activeDisplays().sorted {
        let lhsMain = CGDisplayIsMain($0.id) != 0
        let rhsMain = CGDisplayIsMain($1.id) != 0
        return lhsMain != rhsMain ? lhsMain : $0.uuid < $1.uuid
    }
    let windows = NSWorkspace.shared.runningApplications
        .filter { $0.activationPolicy == .regular && !$0.isHidden && $0.bundleIdentifier != nil && $0.bundleURL != nil }
        .flatMap { standardWindows(of: $0) }
    guard let index = captureDisplayIndex(
        windowFrames: windows.map(\.frame),
        displayFrames: displays.map { Rect(x: $0.bounds.minX, y: $0.bounds.minY, width: $0.bounds.width, height: $0.bounds.height) }
    ) else { throw PresetError("No visible windows on connected displays; nothing saved.") }
    let display = displays[index]
    let chrome = ChromeProfiles.installed()
    var entries: [Entry] = []
    for window in windows where display.bounds.contains(window.frame.center) {
        let app = window.app
        guard let bundleID = app.bundleIdentifier, let path = app.bundleURL?.path else { continue }
        entries.append(Entry(
            bundleID: bundleID,
            appName: app.localizedName ?? bundleID,
            appPath: path,
            chromeProfile: identity(of: window, chrome: chrome).profile,
            frame: window.frame.offset(by: Point(x: -display.origin.x, y: -display.origin.y))
        ))
    }
    try store.save(Preset(name: name, display: display.ref, entries: entries))
    for entry in entries {
        print("saved    \(label(entry)) at \(Int(entry.frame.x)),\(Int(entry.frame.y)) \(Int(entry.frame.width))x\(Int(entry.frame.height))")
    }
    print("Saved \"\(name)\": \(entries.count) windows on \(display.name)")
}

func label(_ entry: Entry) -> String {
    entry.chromeProfile.map { "\(entry.appName) [\($0.label)]" } ?? entry.appName
}
