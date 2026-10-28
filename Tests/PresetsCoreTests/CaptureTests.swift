import Testing
import PresetsCore

struct CaptureTests {
    let main = Rect(x: 0, y: 0, width: 1800, height: 1169)
    let external = Rect(x: -1602, y: -2160, width: 5120, height: 2160)
    let laptopWindow = Rect(x: 0, y: 39, width: 1800, height: 565)
    let workWindow = Rect(x: 104, y: -2130, width: 1706, height: 1065)
    let personalWindow = Rect(x: 1812, y: -2130, width: 1706, height: 1065)

    @Test func captureFollowsWindowsInsteadOfMainDisplay() {
        #expect(captureDisplayIndex(
            windowFrames: [laptopWindow, workWindow, personalWindow],
            displayFrames: [main, external]
        ) == 1)
        #expect(captureDisplayIndex(
            windowFrames: [workWindow, personalWindow, laptopWindow],
            displayFrames: [external, main]
        ) == 0)
        #expect(captureDisplayIndex(
            windowFrames: [workWindow, laptopWindow],
            displayFrames: [main, external]
        ) == 0)
    }

    @Test func captureRequiresAWindowCenterOnTheDisplay() {
        #expect(captureDisplayIndex(windowFrames: [], displayFrames: [main, external]) == nil)
        #expect(captureDisplayIndex(windowFrames: [workWindow], displayFrames: []) == nil)
        let offscreen = Rect(x: 8000, y: 0, width: 800, height: 600)
        #expect(captureDisplayIndex(windowFrames: [offscreen], displayFrames: [main, external]) == nil)
        let boundary = Rect(x: 100, y: -300, width: 800, height: 600)
        #expect(captureDisplayIndex(windowFrames: [boundary], displayFrames: [external, main]) == 1)
    }
}
