import Foundation
import Testing
@testable import PresetsCore

struct ChromeProfilesTests {
    let profiles = ChromeProfiles(localState: Data("""
    {"profile": {"info_cache": {
      "Default": {"name": "Robert Guss"},
      "Profile 5": {"name": "Work"},
      "Profile 1": {"name": "How To Code"}
    }}}
    """.utf8))

    @Test func workTitleResolvesToProfileDirectory() {
        #expect(profiles.profile(fromTitle: "Dashboard - Google Chrome - Robert (Work)")
            == ChromeProfile(directory: "Profile 5", label: "Robert (Work)"))
    }

    @Test func personalTitleResolvesToDefault() {
        #expect(profiles.profile(fromTitle: "robertguss/mac-app-launcher - Google Chrome - Robert (Robert Guss)")?.directory == "Default")
    }

    @Test func pageTitleContainingSuffixUsesLastOccurrence() {
        let title = "Why - Google Chrome - is slow - Google Chrome - Robert (How To Code)"
        #expect(profiles.profile(fromTitle: title)?.directory == "Profile 1")
    }

    @Test func titleWithoutSuffixHasNoProfile() {
        #expect(profiles.profile(fromTitle: "New Tab") == nil)
    }

    @Test func unknownLabelKeepsLabelWithoutDirectory() {
        #expect(profiles.profile(fromTitle: "Tab - Google Chrome - Someone (Gone)")
            == ChromeProfile(directory: nil, label: "Someone (Gone)"))
    }
}
