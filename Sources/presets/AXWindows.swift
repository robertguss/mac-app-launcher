import AppKit
import ApplicationServices
import PresetsCore

struct AXWindow {
    let element: AXUIElement
    let app: NSRunningApplication
    let title: String
    let frame: Rect
}

func attribute<T>(_ element: AXUIElement, _ name: String) -> T? {
    var value: CFTypeRef?
    guard AXUIElementCopyAttributeValue(element, name as CFString, &value) == .success else { return nil }
    return value as? T
}

private func valueAttribute(_ element: AXUIElement, _ name: String) -> AXValue? {
    var value: CFTypeRef?
    guard AXUIElementCopyAttributeValue(element, name as CFString, &value) == .success, let value,
          CFGetTypeID(value) == AXValueGetTypeID() else { return nil }
    return (value as! AXValue)
}

func frame(of element: AXUIElement) -> Rect? {
    guard let positionValue = valueAttribute(element, kAXPositionAttribute),
          let sizeValue = valueAttribute(element, kAXSizeAttribute) else { return nil }
    var position = CGPoint.zero
    var size = CGSize.zero
    AXValueGetValue(positionValue, .cgPoint, &position)
    AXValueGetValue(sizeValue, .cgSize, &size)
    return Rect(x: position.x, y: position.y, width: size.width, height: size.height)
}

func standardWindows(of app: NSRunningApplication, includingMinimized: Bool = false) -> [AXWindow] {
    let appElement = AXUIElementCreateApplication(app.processIdentifier)
    let elements: [AXUIElement] = attribute(appElement, kAXWindowsAttribute) ?? []
    return elements.compactMap { element in
        guard attribute(element, kAXSubroleAttribute) as String? == kAXStandardWindowSubrole,
              includingMinimized || attribute(element, kAXMinimizedAttribute) as Bool? != true,
              let frame = frame(of: element) else { return nil }
        return AXWindow(element: element, app: app, title: attribute(element, kAXTitleAttribute) ?? "", frame: frame)
    }
}

func identity(of window: AXWindow, chrome: ChromeProfiles) -> WindowIdentity {
    let bundleID = window.app.bundleIdentifier ?? ""
    let profile = bundleID == ChromeProfiles.bundleID ? chrome.profile(fromTitle: window.title) : nil
    return WindowIdentity(bundleID: bundleID, profile: profile)
}

private let enhancedUserInterface = "AXEnhancedUserInterface"

func move(_ window: AXWindow, to target: Rect) -> Rect? {
    let appElement = AXUIElementCreateApplication(window.app.processIdentifier)
    let enhanced = attribute(appElement, enhancedUserInterface) as Bool? == true
    if enhanced { AXUIElementSetAttributeValue(appElement, enhancedUserInterface as CFString, kCFBooleanFalse) }
    defer { if enhanced { AXUIElementSetAttributeValue(appElement, enhancedUserInterface as CFString, kCFBooleanTrue) } }

    var position = CGPoint(x: target.x, y: target.y)
    var size = CGSize(width: target.width, height: target.height)
    let positionValue = AXValueCreate(.cgPoint, &position)!
    let sizeValue = AXValueCreate(.cgSize, &size)!
    var landed: Rect?
    for attempt in 0..<5 {
        if attempt > 0 { usleep(100_000) }
        AXUIElementSetAttributeValue(window.element, kAXPositionAttribute as CFString, positionValue)
        AXUIElementSetAttributeValue(window.element, kAXSizeAttribute as CFString, sizeValue)
        AXUIElementSetAttributeValue(window.element, kAXPositionAttribute as CFString, positionValue)
        landed = frame(of: window.element)
        if landed?.isClose(to: target) == true { break }
    }
    return landed
}

extension Rect {
    var center: CGPoint { CGPoint(x: x + width / 2, y: y + height / 2) }
}
