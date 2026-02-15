import XCTest
@testable import GhosttyLayoutLib

final class ConfigTests: XCTestCase {

    // MARK: - KeyBinding

    func testKeyBindingInit() {
        let binding = KeyBinding(key: "d", modifiers: ["command"])
        XCTAssertEqual(binding.key, "d")
        XCTAssertEqual(binding.modifiers, ["command"])
    }

    func testKeyBindingInitDefaultModifiers() {
        let binding = KeyBinding(key: "space")
        XCTAssertEqual(binding.key, "space")
        XCTAssertTrue(binding.modifiers.isEmpty)
    }

    func testKeyBindingCodableRoundTrip() throws {
        let original = KeyBinding(key: "d", modifiers: ["command", "shift"])
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(KeyBinding.self, from: data)
        XCTAssertEqual(decoded.key, original.key)
        XCTAssertEqual(decoded.modifiers, original.modifiers)
    }

    func testKeyBindingWithEmptyModifiers() throws {
        let original = KeyBinding(key: "space", modifiers: [])
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(KeyBinding.self, from: data)
        XCTAssertEqual(decoded.key, "space")
        XCTAssertTrue(decoded.modifiers.isEmpty)
    }

    func testKeyBindingWithMultipleModifiers() throws {
        let original = KeyBinding(key: "d", modifiers: ["command", "shift", "control"])
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(KeyBinding.self, from: data)
        XCTAssertEqual(decoded.modifiers.count, 3)
    }

    // MARK: - defaultConfig

    func testDefaultConfigSplitRight() {
        XCTAssertEqual(Config.defaultConfig.splitRight.key, "d")
        XCTAssertEqual(Config.defaultConfig.splitRight.modifiers, ["command"])
    }

    func testDefaultConfigSplitDown() {
        XCTAssertEqual(Config.defaultConfig.splitDown.key, "d")
        XCTAssertEqual(Config.defaultConfig.splitDown.modifiers, ["command", "shift"])
    }

    func testDefaultConfigGotoLeft() {
        XCTAssertEqual(Config.defaultConfig.gotoLeft.key, "left")
        XCTAssertTrue(Config.defaultConfig.gotoLeft.modifiers.contains("command"))
        XCTAssertTrue(Config.defaultConfig.gotoLeft.modifiers.contains("control"))
    }

    func testDefaultConfigGotoRight() {
        XCTAssertEqual(Config.defaultConfig.gotoRight.key, "right")
    }

    func testDefaultConfigGotoUp() {
        XCTAssertEqual(Config.defaultConfig.gotoUp.key, "up")
    }

    func testDefaultConfigGotoDown() {
        XCTAssertEqual(Config.defaultConfig.gotoDown.key, "down")
    }

    func testDefaultConfigEqualizeSplits() {
        XCTAssertNotNil(Config.defaultConfig.equalizeSplits)
        XCTAssertEqual(Config.defaultConfig.equalizeSplits?.key, "=")
    }

    func testDefaultConfigNoPrefix() {
        XCTAssertNil(Config.defaultConfig.prefix)
    }

    // MARK: - Config Codable

    func testConfigCodableRoundTrip() throws {
        let original = Config.defaultConfig
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(original)
        let decoded = try JSONDecoder().decode(Config.self, from: data)

        XCTAssertEqual(decoded.splitRight.key, original.splitRight.key)
        XCTAssertEqual(decoded.splitDown.key, original.splitDown.key)
        XCTAssertEqual(decoded.gotoLeft.key, original.gotoLeft.key)
        XCTAssertEqual(decoded.gotoRight.key, original.gotoRight.key)
        XCTAssertEqual(decoded.gotoUp.key, original.gotoUp.key)
        XCTAssertEqual(decoded.gotoDown.key, original.gotoDown.key)
    }

    func testConfigWithPrefixCodableRoundTrip() throws {
        let config = Config(
            prefix: KeyBinding(key: "t", modifiers: ["control"]),
            splitRight: KeyBinding(key: "backslash", modifiers: ["shift"]),
            splitDown: KeyBinding(key: "-"),
            gotoLeft: KeyBinding(key: "h"),
            gotoRight: KeyBinding(key: "l"),
            gotoUp: KeyBinding(key: "k"),
            gotoDown: KeyBinding(key: "j"),
            equalizeSplits: KeyBinding(key: "=")
        )

        let data = try JSONEncoder().encode(config)
        let decoded = try JSONDecoder().decode(Config.self, from: data)

        XCTAssertNotNil(decoded.prefix)
        XCTAssertEqual(decoded.prefix?.key, "t")
        XCTAssertEqual(decoded.splitRight.key, "backslash")
    }

    func testConfigWithoutEqualizeSplitsCodableRoundTrip() throws {
        let config = Config(
            prefix: nil,
            splitRight: KeyBinding(key: "d", modifiers: ["command"]),
            splitDown: KeyBinding(key: "d", modifiers: ["command", "shift"]),
            gotoLeft: KeyBinding(key: "left"),
            gotoRight: KeyBinding(key: "right"),
            gotoUp: KeyBinding(key: "up"),
            gotoDown: KeyBinding(key: "down"),
            equalizeSplits: nil
        )

        let data = try JSONEncoder().encode(config)
        let decoded = try JSONDecoder().decode(Config.self, from: data)

        XCTAssertNil(decoded.prefix)
        XCTAssertNil(decoded.equalizeSplits)
    }

    // MARK: - configPath

    func testConfigPathContainsGhosttyLayout() {
        XCTAssertTrue(Config.configPath.path.contains("ghostty-layout"))
    }

    func testConfigPathEndsWithJSON() {
        XCTAssertTrue(Config.configPath.path.hasSuffix("config.json"))
    }

    // MARK: - JSON出力のフォーマット

    func testConfigJSONContainsAllKeys() throws {
        let config = Config.defaultConfig
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(config)
        let jsonString = String(data: data, encoding: .utf8)!

        XCTAssertTrue(jsonString.contains("splitRight"))
        XCTAssertTrue(jsonString.contains("splitDown"))
        XCTAssertTrue(jsonString.contains("gotoLeft"))
        XCTAssertTrue(jsonString.contains("gotoRight"))
        XCTAssertTrue(jsonString.contains("gotoUp"))
        XCTAssertTrue(jsonString.contains("gotoDown"))
        XCTAssertTrue(jsonString.contains("equalizeSplits"))
    }
}
