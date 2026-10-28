import AppKit
import PresetsCore

func save(name: String, store: PresetStore) throws {
    let display = saveDisplay(in: activeDisplays())
    let chrome = ChromeProfiles.installed()
    var entries: [Entry] = []
    for app in NSWorkspace.shared.runningApplications where app.activationPolicy == .regular && !app.isHidden {
        guard let bundleID = app.bundleIdentifier, let path = app.bundleURL?.path else { continue }
        for window in standardWindows(of: app) where display.bounds.contains(window.frame.center) {
            entries.append(Entry(
                bundleID: bundleID,
                appName: app.localizedName ?? bundleID,
                appPath: path,
                chromeProfile: identity(of: window, chrome: chrome).profile,
                frame: window.frame.offset(by: Point(x: -display.origin.x, y: -display.origin.y))
            ))
        }
    }
    guard !entries.isEmpty else { throw PresetError("No visible windows on \(display.name); nothing saved.") }
    try store.save(Preset(name: name, display: display.ref, entries: entries))
    for entry in entries {
        print("saved    \(label(entry)) at \(Int(entry.frame.x)),\(Int(entry.frame.y)) \(Int(entry.frame.width))x\(Int(entry.frame.height))")
    }
    print("Saved \"\(name)\": \(entries.count) windows on \(display.name)")
}

private func saveDisplay(in displays: [Display]) -> Display {
    if let app = NSWorkspace.shared.frontmostApplication,
       let window = elementAttribute(AXUIElementCreateApplication(app.processIdentifier), kAXFocusedWindowAttribute),
       let frame = frame(of: window),
       let display = displays.first(where: { $0.bounds.contains(frame.center) }) {
        return display
    }
    return displays.first { CGDisplayIsMain($0.id) != 0 } ?? displays[0]
}

func label(_ entry: Entry) -> String {
    entry.chromeProfile.map { "\(entry.appName) [\($0.label)]" } ?? entry.appName
}
