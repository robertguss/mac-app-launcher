import Testing
@testable import PresetsCore

struct MatchingTests {
    let work = ChromeProfile(directory: "Profile 5", label: "Robert (Work)")
    let personal = ChromeProfile(directory: "Default", label: "Robert (Robert Guss)")

    func entry(_ bundleID: String, _ profile: ChromeProfile? = nil) -> Entry {
        Entry(bundleID: bundleID, appName: bundleID, appPath: "", chromeProfile: profile,
              frame: Rect(x: 0, y: 0, width: 1, height: 1))
    }

    func window(_ id: Int, _ bundleID: String, _ profile: ChromeProfile? = nil) -> LiveWindow<Int> {
        LiveWindow(handle: id, identity: WindowIdentity(bundleID: bundleID, profile: profile))
    }

    @Test func frontmostOfSeveralMatchingWindowsIsAssigned() {
        let windows = [window(1, "com.google.Chrome", work), window(2, "com.google.Chrome", work), window(3, "com.google.Chrome", work)]
        #expect(assign(entries: [entry("com.google.Chrome", work)], to: windows) == [0: 1])
    }

    @Test func repeatedEntriesTakeFrontmostWindowsInOrder() {
        let windows = [window(7, "com.github.wez.wezterm"), window(8, "com.github.wez.wezterm"), window(9, "com.github.wez.wezterm")]
        let entries = [entry("com.github.wez.wezterm"), entry("com.github.wez.wezterm")]
        #expect(assign(entries: entries, to: windows) == [0: 7, 1: 8])
    }

    @Test func chromeProfilesNeverTakeEachOthersWindows() {
        let windows = [window(1, "com.google.Chrome", personal), window(2, "com.google.Chrome", work)]
        let entries = [entry("com.google.Chrome", work), entry("com.google.Chrome", personal)]
        #expect(assign(entries: entries, to: windows) == [0: 2, 1: 1])
    }

    @Test func entryWithoutLiveWindowIsUnassigned() {
        let entries = [entry("notion.id"), entry("com.todesktop.230313mzl4w4u92")]
        #expect(assign(entries: entries, to: [window(4, "notion.id")]) == [0: 4])
    }

    @Test func relativeFrameMapsOntoMovedDisplay() {
        let frame = Rect(x: 600, y: 400, width: 600, height: 500)
        #expect(frame.offset(by: Point(x: -1800, y: -1080)) == Rect(x: -1200, y: -680, width: 600, height: 500))
    }
}
