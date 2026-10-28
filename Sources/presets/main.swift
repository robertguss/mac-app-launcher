import ApplicationServices
import Foundation
import PresetsCore

let usage = "usage: presets save <name> | presets apply <name>"
let arguments = Array(CommandLine.arguments.dropFirst())

guard arguments.count == 2, !arguments[1].isEmpty, !arguments[1].contains("/") else { fail(usage) }
guard AXIsProcessTrusted() else {
    fail("Accessibility permission is missing. Open System Settings → Privacy & Security → Accessibility and turn on the app that runs presets (Raycast or your terminal).")
}

do {
    switch arguments[0] {
    case "save": try save(name: arguments[1], store: .standard())
    case "apply": try await apply(name: arguments[1], store: .standard())
    default: fail(usage)
    }
} catch {
    fail("\(error)")
}

func fail(_ message: String) -> Never {
    FileHandle.standardError.write(Data((message + "\n").utf8))
    exit(1)
}
