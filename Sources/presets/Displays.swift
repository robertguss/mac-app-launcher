import AppKit
import PresetsCore

struct Display {
    let id: CGDirectDisplayID
    let uuid: String
    let name: String
    let bounds: CGRect

    var origin: Point { Point(x: bounds.minX, y: bounds.minY) }
    var ref: DisplayRef { DisplayRef(uuid: uuid, name: name, width: bounds.width, height: bounds.height) }
}

func activeDisplays() -> [Display] {
    var count: UInt32 = 0
    CGGetActiveDisplayList(0, nil, &count)
    var ids = [CGDirectDisplayID](repeating: 0, count: Int(count))
    CGGetActiveDisplayList(count, &ids, &count)
    return ids.map { id in
        let uuid = CGDisplayCreateUUIDFromDisplayID(id).map { CFUUIDCreateString(nil, $0.takeRetainedValue()) as String } ?? "\(id)"
        let screen = NSScreen.screens.first {
            ($0.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber)?.uint32Value == id
        }
        return Display(id: id, uuid: uuid, name: screen?.localizedName ?? "Display \(id)", bounds: CGDisplayBounds(id))
    }
}
