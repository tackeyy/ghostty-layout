import XCTest
@testable import GhosttyLayoutLib

final class KeySenderTests: XCTestCase {

    // MARK: - Modifiers.from()

    func testModifiersFromCommand() {
        let mods = KeySender.Modifiers.from(["command"])
        XCTAssertTrue(mods.contains(.command))
        XCTAssertFalse(mods.contains(.shift))
    }

    func testModifiersFromShift() {
        let mods = KeySender.Modifiers.from(["shift"])
        XCTAssertTrue(mods.contains(.shift))
    }

    func testModifiersFromOption() {
        let mods = KeySender.Modifiers.from(["option"])
        XCTAssertTrue(mods.contains(.option))
    }

    func testModifiersFromControl() {
        let mods = KeySender.Modifiers.from(["control"])
        XCTAssertTrue(mods.contains(.control))
    }

    func testModifiersFromMultiple() {
        let mods = KeySender.Modifiers.from(["command", "shift", "control"])
        XCTAssertTrue(mods.contains(.command))
        XCTAssertTrue(mods.contains(.shift))
        XCTAssertTrue(mods.contains(.control))
    }

    // エイリアス
    func testModifiersFromAliasCmd() {
        let mods = KeySender.Modifiers.from(["cmd"])
        XCTAssertTrue(mods.contains(.command))
    }

    func testModifiersFromAliasSuper() {
        let mods = KeySender.Modifiers.from(["super"])
        XCTAssertTrue(mods.contains(.command))
    }

    func testModifiersFromAliasCtrl() {
        let mods = KeySender.Modifiers.from(["ctrl"])
        XCTAssertTrue(mods.contains(.control))
    }

    func testModifiersFromAliasOpt() {
        let mods = KeySender.Modifiers.from(["opt"])
        XCTAssertTrue(mods.contains(.option))
    }

    func testModifiersFromAliasAlt() {
        let mods = KeySender.Modifiers.from(["alt"])
        XCTAssertTrue(mods.contains(.option))
    }

    func testModifiersFromEmpty() {
        let mods = KeySender.Modifiers.from([])
        XCTAssertTrue(mods.isEmpty)
    }

    func testModifiersFromUnknownKeyIgnored() {
        // unknown は無視される（警告が出る）
        let mods = KeySender.Modifiers.from(["unknown"])
        XCTAssertTrue(mods.isEmpty)
    }

    func testModifiersFromCaseInsensitive() {
        let mods = KeySender.Modifiers.from(["COMMAND", "SHIFT"])
        // lowercased() されるので認識される
        XCTAssertTrue(mods.contains(.command))
        XCTAssertTrue(mods.contains(.shift))
    }

    // MARK: - Modifiers OptionSet

    func testModifiersOptionSetUnion() {
        let mods: KeySender.Modifiers = [.command, .shift]
        XCTAssertTrue(mods.contains(.command))
        XCTAssertTrue(mods.contains(.shift))
        XCTAssertFalse(mods.contains(.option))
    }

    func testModifiersOptionSetEmpty() {
        let mods: KeySender.Modifiers = []
        XCTAssertTrue(mods.isEmpty)
    }
}
