import XCTest
@testable import GhosttyLayoutLib

final class GhosttyConfigParserTests: XCTestCase {

    // MARK: - parseContent() 標準設定

    func testParseContentStandardConfig() {
        let content = """
        keybind = cmd+d=new_split:right
        keybind = cmd+shift+d=new_split:down
        keybind = cmd+ctrl+left=goto_split:left
        keybind = cmd+ctrl+right=goto_split:right
        keybind = cmd+ctrl+up=goto_split:up
        keybind = cmd+ctrl+down=goto_split:down
        """
        let config = GhosttyConfigParser.parseContent(content)
        XCTAssertNotNil(config)
        XCTAssertEqual(config?.splitRight.key, "d")
        XCTAssertTrue(config?.splitRight.modifiers.contains("command") ?? false)
        XCTAssertEqual(config?.splitDown.key, "d")
        XCTAssertTrue(config?.splitDown.modifiers.contains("shift") ?? false)
    }

    func testParseContentNavigationKeys() {
        let content = """
        keybind = cmd+ctrl+left=goto_split:left
        keybind = cmd+ctrl+right=goto_split:right
        keybind = cmd+ctrl+up=goto_split:up
        keybind = cmd+ctrl+down=goto_split:down
        keybind = cmd+d=new_split:right
        keybind = cmd+shift+d=new_split:down
        """
        let config = GhosttyConfigParser.parseContent(content)
        XCTAssertEqual(config?.gotoLeft.key, "left")
        XCTAssertEqual(config?.gotoRight.key, "right")
        XCTAssertEqual(config?.gotoUp.key, "up")
        XCTAssertEqual(config?.gotoDown.key, "down")
    }

    // MARK: - コメント・空行

    func testParseContentSkipsComments() {
        let content = """
        # This is a comment
        keybind = cmd+d=new_split:right
        # Another comment
        keybind = cmd+shift+d=new_split:down
        keybind = cmd+ctrl+left=goto_split:left
        keybind = cmd+ctrl+right=goto_split:right
        keybind = cmd+ctrl+up=goto_split:up
        keybind = cmd+ctrl+down=goto_split:down
        """
        let config = GhosttyConfigParser.parseContent(content)
        XCTAssertNotNil(config)
        XCTAssertEqual(config?.splitRight.key, "d")
    }

    func testParseContentSkipsEmptyLines() {
        let content = """
        keybind = cmd+d=new_split:right

        keybind = cmd+shift+d=new_split:down

        keybind = cmd+ctrl+left=goto_split:left
        keybind = cmd+ctrl+right=goto_split:right
        keybind = cmd+ctrl+up=goto_split:up
        keybind = cmd+ctrl+down=goto_split:down
        """
        let config = GhosttyConfigParser.parseContent(content)
        XCTAssertNotNil(config)
    }

    // MARK: - keybindなし / 不足

    func testParseContentNoKeybinds() {
        let content = """
        font-size = 14
        theme = dark
        """
        let config = GhosttyConfigParser.parseContent(content)
        XCTAssertNil(config)
    }

    func testParseContentEmptyString() {
        let config = GhosttyConfigParser.parseContent("")
        XCTAssertNil(config)
    }

    func testParseContentNoRelevantActions() {
        let content = """
        keybind = cmd+t=new_tab
        keybind = cmd+w=close_surface
        """
        let config = GhosttyConfigParser.parseContent(content)
        XCTAssertNil(config)
    }

    func testParseContentPartialKeybinds() {
        // new_split:right のみ → 残りはデフォルト
        let content = """
        keybind = cmd+d=new_split:right
        """
        let config = GhosttyConfigParser.parseContent(content)
        XCTAssertNotNil(config)
        XCTAssertEqual(config?.splitRight.key, "d")
        // デフォルト値にフォールバック
        XCTAssertEqual(config?.splitDown.key, Config.defaultConfig.splitDown.key)
    }

    // MARK: - プレフィックス付き

    func testParseContentWithPrefix() {
        let content = """
        keybind = ctrl+t>shift+backslash=new_split:right
        keybind = ctrl+t>minus=new_split:down
        keybind = ctrl+t>h=goto_split:left
        keybind = ctrl+t>l=goto_split:right
        keybind = ctrl+t>k=goto_split:up
        keybind = ctrl+t>j=goto_split:down
        """
        let config = GhosttyConfigParser.parseContent(content)
        XCTAssertNotNil(config)
        XCTAssertNotNil(config?.prefix)
        XCTAssertEqual(config?.prefix?.key, "t")
        XCTAssertTrue(config?.prefix?.modifiers.contains("control") ?? false)
    }

    func testParseContentPrefixKeyExtracted() {
        let content = """
        keybind = ctrl+t>shift+backslash=new_split:right
        keybind = ctrl+t>minus=new_split:down
        keybind = ctrl+t>h=goto_split:left
        keybind = ctrl+t>l=goto_split:right
        keybind = ctrl+t>k=goto_split:up
        keybind = ctrl+t>j=goto_split:down
        """
        let config = GhosttyConfigParser.parseContent(content)
        // プレフィックス除去後のキーが正しいか
        XCTAssertEqual(config?.splitRight.key, "backslash")
        XCTAssertEqual(config?.splitDown.key, "minus")
        XCTAssertEqual(config?.gotoLeft.key, "h")
        XCTAssertEqual(config?.gotoRight.key, "l")
        XCTAssertEqual(config?.gotoUp.key, "k")
        XCTAssertEqual(config?.gotoDown.key, "j")
    }

    func testParseContentWithoutPrefix() {
        let content = """
        keybind = cmd+d=new_split:right
        keybind = cmd+shift+d=new_split:down
        keybind = cmd+ctrl+left=goto_split:left
        keybind = cmd+ctrl+right=goto_split:right
        keybind = cmd+ctrl+up=goto_split:up
        keybind = cmd+ctrl+down=goto_split:down
        """
        let config = GhosttyConfigParser.parseContent(content)
        XCTAssertNil(config?.prefix)
    }

    // MARK: - equalize_splits

    func testParseContentWithEqualizeSplits() {
        let content = """
        keybind = cmd+d=new_split:right
        keybind = cmd+shift+d=new_split:down
        keybind = cmd+ctrl+left=goto_split:left
        keybind = cmd+ctrl+right=goto_split:right
        keybind = cmd+ctrl+up=goto_split:up
        keybind = cmd+ctrl+down=goto_split:down
        keybind = cmd+ctrl+e=equalize_splits
        """
        let config = GhosttyConfigParser.parseContent(content)
        XCTAssertNotNil(config?.equalizeSplits)
        XCTAssertEqual(config?.equalizeSplits?.key, "e")
    }

    func testParseContentWithoutEqualizeSplits() {
        let content = """
        keybind = cmd+d=new_split:right
        keybind = cmd+shift+d=new_split:down
        keybind = cmd+ctrl+left=goto_split:left
        keybind = cmd+ctrl+right=goto_split:right
        keybind = cmd+ctrl+up=goto_split:up
        keybind = cmd+ctrl+down=goto_split:down
        """
        let config = GhosttyConfigParser.parseContent(content)
        XCTAssertNil(config?.equalizeSplits)
    }

    // MARK: - 修飾キーエイリアス

    func testParseContentModifierAliasCtrl() {
        let content = """
        keybind = ctrl+d=new_split:right
        keybind = control+shift+d=new_split:down
        keybind = ctrl+left=goto_split:left
        keybind = ctrl+right=goto_split:right
        keybind = ctrl+up=goto_split:up
        keybind = ctrl+down=goto_split:down
        """
        let config = GhosttyConfigParser.parseContent(content)
        // ctrl と control が同じ "control" に解決される
        XCTAssertTrue(config?.splitRight.modifiers.contains("control") ?? false)
        XCTAssertTrue(config?.splitDown.modifiers.contains("control") ?? false)
    }

    func testParseContentModifierAliasCmd() {
        let content1 = "keybind = cmd+d=new_split:right\nkeybind = cmd+shift+d=new_split:down\nkeybind = cmd+left=goto_split:left\nkeybind = cmd+right=goto_split:right\nkeybind = cmd+up=goto_split:up\nkeybind = cmd+down=goto_split:down"
        let content2 = "keybind = command+d=new_split:right\nkeybind = command+shift+d=new_split:down\nkeybind = command+left=goto_split:left\nkeybind = command+right=goto_split:right\nkeybind = command+up=goto_split:up\nkeybind = command+down=goto_split:down"
        let content3 = "keybind = super+d=new_split:right\nkeybind = super+shift+d=new_split:down\nkeybind = super+left=goto_split:left\nkeybind = super+right=goto_split:right\nkeybind = super+up=goto_split:up\nkeybind = super+down=goto_split:down"

        let config1 = GhosttyConfigParser.parseContent(content1)
        let config2 = GhosttyConfigParser.parseContent(content2)
        let config3 = GhosttyConfigParser.parseContent(content3)

        // 全て "command" に解決
        XCTAssertTrue(config1?.splitRight.modifiers.contains("command") ?? false)
        XCTAssertTrue(config2?.splitRight.modifiers.contains("command") ?? false)
        XCTAssertTrue(config3?.splitRight.modifiers.contains("command") ?? false)
    }

    // MARK: - keybind以外の行

    func testParseContentIgnoresNonKeybindLines() {
        let content = """
        font-size = 14
        theme = dark
        keybind = cmd+d=new_split:right
        keybind = cmd+shift+d=new_split:down
        keybind = cmd+ctrl+left=goto_split:left
        keybind = cmd+ctrl+right=goto_split:right
        keybind = cmd+ctrl+up=goto_split:up
        keybind = cmd+ctrl+down=goto_split:down
        window-padding-x = 10
        """
        let config = GhosttyConfigParser.parseContent(content)
        XCTAssertNotNil(config)
        XCTAssertEqual(config?.splitRight.key, "d")
    }

    // MARK: - 重複

    func testParseContentDuplicateKeybindsLastWins() {
        let content = """
        keybind = cmd+d=new_split:right
        keybind = cmd+e=new_split:right
        keybind = cmd+shift+d=new_split:down
        keybind = cmd+ctrl+left=goto_split:left
        keybind = cmd+ctrl+right=goto_split:right
        keybind = cmd+ctrl+up=goto_split:up
        keybind = cmd+ctrl+down=goto_split:down
        """
        let config = GhosttyConfigParser.parseContent(content)
        // 後勝ち: cmd+e が new_split:right に使われる
        XCTAssertEqual(config?.splitRight.key, "e")
    }

    // MARK: - スペーシング

    func testParseContentVariousSpacing() {
        let content = """
        keybind=cmd+d=new_split:right
        keybind =cmd+shift+d=new_split:down
        keybind= cmd+ctrl+left=goto_split:left
        keybind = cmd+ctrl+right=goto_split:right
        keybind  =  cmd+ctrl+up=goto_split:up
        keybind = cmd+ctrl+down=goto_split:down
        """
        let config = GhosttyConfigParser.parseContent(content)
        XCTAssertNotNil(config)
    }

    // MARK: - configPaths

    func testConfigPathsNotEmpty() {
        XCTAssertFalse(GhosttyConfigParser.configPaths.isEmpty)
    }

    func testConfigPathsContainExpectedPaths() {
        let paths = GhosttyConfigParser.configPaths.map { $0.path }
        XCTAssertTrue(paths.contains(where: { $0.contains(".config/ghostty/config") }))
        XCTAssertTrue(paths.contains(where: { $0.contains("com.mitchellh.ghostty/config") }))
    }
}
