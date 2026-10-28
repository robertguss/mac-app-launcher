public func captureDisplayIndex(windowFrames: [Rect], displayFrames: [Rect]) -> Int? {
    var selected: Int?
    var mostWindows = 0
    for (index, display) in displayFrames.enumerated() {
        let count = windowFrames.filter { window in
            let x = window.x + window.width / 2
            let y = window.y + window.height / 2
            return x >= display.x && x < display.x + display.width
                && y >= display.y && y < display.y + display.height
        }.count
        if count > mostWindows {
            selected = index
            mostWindows = count
        }
    }
    return selected
}
