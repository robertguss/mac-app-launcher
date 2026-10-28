import AppKit
import PresetsCore

private let windowWait: TimeInterval = 10

func apply(name: String, store: PresetStore) async throws {
    let started = Date()
    let preset = try store.load(name)
    let chrome = ChromeProfiles.installed()
    let keep = Set(preset.entries.map(\.bundleID))

    for app in NSWorkspace.shared.runningApplications where app.isHidden && keep.contains(app.bundleIdentifier ?? "") {
        app.unhide()
    }

    let deadline = Date().addingTimeInterval(windowWait)
    var assignments = assign(entries: preset.entries, to: liveWindows(of: keep, chrome: chrome))
    let missing = preset.entries.indices.filter { assignments[$0] == nil }.map { preset.entries[$0] }
    await open(missing, until: deadline)

    guard let display = activeDisplays().first(where: { $0.uuid == preset.display.uuid }) else {
        let hidden = hideApps(except: keep)
        print("Display \"\(preset.display.name)\" is not connected: opened \(Set(missing.map(\.bundleID)).count) apps, moved no windows, hid \(hidden.count) apps.")
        return
    }

    while preset.entries.indices.contains(where: { assignments[$0] == nil }), Date() < deadline {
        usleep(150_000)
        assignments = assign(entries: preset.entries, to: liveWindows(of: keep, chrome: chrome))
    }

    var placed = 0, inPlace = 0, skipped = 0
    for (index, entry) in preset.entries.enumerated() {
        guard let window = assignments[index] else {
            print("skipped  \(label(entry)): no window within \(Int(windowWait)) s")
            skipped += 1
            continue
        }
        if attribute(window.element, kAXMinimizedAttribute) as Bool? == true {
            guard AXUIElementSetAttributeValue(window.element, kAXMinimizedAttribute as CFString, kCFBooleanFalse) == .success else {
                print("skipped  \(label(entry)): window refused to un-minimize")
                skipped += 1
                continue
            }
        }
        let target = entry.frame.offset(by: display.origin)
        if frame(of: window.element)?.isClose(to: target) == true {
            print("in place \(label(entry))")
            inPlace += 1
        } else if let landed = move(window, to: target), landed.isClose(to: target) {
            print("placed   \(label(entry))")
            placed += 1
        } else {
            print("skipped  \(label(entry)): window refused the saved frame")
            skipped += 1
        }
    }

    let hidden = hideApps(except: keep)
    if !hidden.isEmpty { print("hidden   \(hidden.joined(separator: ", "))") }
    let seconds = String(format: "%.1f", Date().timeIntervalSince(started))
    print("Applied \"\(name)\" in \(seconds) s: \(placed) placed, \(inPlace) already in place, \(skipped) skipped, \(hidden.count) hidden")
}

private func liveWindows(of bundleIDs: Set<String>, chrome: ChromeProfiles) -> [LiveWindow<AXWindow>] {
    NSWorkspace.shared.runningApplications
        .filter { bundleIDs.contains($0.bundleIdentifier ?? "") }
        .flatMap { standardWindows(of: $0, includingMinimized: true) }
        .map { LiveWindow(handle: $0, identity: identity(of: $0, chrome: chrome)) }
}

private func open(_ entries: [Entry], until deadline: Date) async {
    let chromeEntries = entries.filter { $0.bundleID == ChromeProfiles.bundleID }
    await withTaskGroup(of: Void.self) { group in
        for entry in entries where entry.bundleID != ChromeProfiles.bundleID {
            group.addTask { await open(entry) }
        }
        group.addTask {
            for (index, entry) in chromeEntries.enumerated() {
                if index > 0 { await waitForChromeWindow(until: deadline) }
                await open(entry)
            }
        }
    }
}

private func waitForChromeWindow(until deadline: Date) async {
    while Date() < deadline {
        let chromeApps = NSRunningApplication.runningApplications(withBundleIdentifier: ChromeProfiles.bundleID)
        if chromeApps.contains(where: { !standardWindows(of: $0).isEmpty }) { return }
        try? await Task.sleep(nanoseconds: 150_000_000)
    }
}

private func open(_ entry: Entry) async {
    let url = FileManager.default.fileExists(atPath: entry.appPath)
        ? URL(fileURLWithPath: entry.appPath)
        : NSWorkspace.shared.urlForApplication(withBundleIdentifier: entry.bundleID)
    guard let url else {
        print("missing  \(label(entry)): app is not installed")
        return
    }
    let configuration = NSWorkspace.OpenConfiguration()
    configuration.activates = false
    if entry.bundleID == ChromeProfiles.bundleID, let directory = entry.chromeProfile?.directory {
        configuration.createsNewApplicationInstance = true
        configuration.arguments = ["--profile-directory=\(directory)"]
    }
    do {
        _ = try await NSWorkspace.shared.openApplication(at: url, configuration: configuration)
    } catch {
        print("failed   \(label(entry)): \(error.localizedDescription)")
    }
}

private func hideApps(except keep: Set<String>) -> [String] {
    let apps = NSWorkspace.shared.runningApplications
        .filter { $0.activationPolicy == .regular && !$0.isHidden && $0.processIdentifier != getpid() && !keep.contains($0.bundleIdentifier ?? "") }
    apps.forEach { $0.hide() }
    return apps.map { $0.localizedName ?? $0.bundleIdentifier ?? "\($0.processIdentifier)" }
}
