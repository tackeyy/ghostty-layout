import XCTest
@testable import GhosttyLayoutLib

final class GridLayoutTests: XCTestCase {

    // MARK: - parse() プリセット

    func testParseH() {
        let layout = GridLayout.parse("h")
        XCTAssertNotNil(layout)
        XCTAssertEqual(layout?.columns, 2)
        XCTAssertEqual(layout?.rows, 1)
    }

    func testParseV() {
        let layout = GridLayout.parse("v")
        XCTAssertNotNil(layout)
        XCTAssertEqual(layout?.columns, 1)
        XCTAssertEqual(layout?.rows, 2)
    }

    func testParse4() {
        let layout = GridLayout.parse("4")
        XCTAssertNotNil(layout)
        XCTAssertEqual(layout?.columns, 2)
        XCTAssertEqual(layout?.rows, 2)
    }

    func testParse6() {
        let layout = GridLayout.parse("6")
        XCTAssertNotNil(layout)
        XCTAssertEqual(layout?.columns, 2)
        XCTAssertEqual(layout?.rows, 3)
    }

    func testParse8() {
        let layout = GridLayout.parse("8")
        XCTAssertNotNil(layout)
        XCTAssertEqual(layout?.columns, 4)
        XCTAssertEqual(layout?.rows, 2)
    }

    func testParse9() {
        let layout = GridLayout.parse("9")
        XCTAssertNotNil(layout)
        XCTAssertEqual(layout?.columns, 3)
        XCTAssertEqual(layout?.rows, 3)
    }

    // MARK: - parse() カスタムグリッド

    func testParseCustom2x3() {
        let layout = GridLayout.parse("2x3")
        XCTAssertEqual(layout?.columns, 2)
        XCTAssertEqual(layout?.rows, 3)
    }

    func testParseCustom3x2() {
        let layout = GridLayout.parse("3x2")
        XCTAssertEqual(layout?.columns, 3)
        XCTAssertEqual(layout?.rows, 2)
    }

    func testParseCustom1x1() {
        let layout = GridLayout.parse("1x1")
        XCTAssertEqual(layout?.columns, 1)
        XCTAssertEqual(layout?.rows, 1)
    }

    func testParseCustom8x8() {
        let layout = GridLayout.parse("8x8")
        XCTAssertEqual(layout?.columns, 8)
        XCTAssertEqual(layout?.rows, 8)
    }

    func testParseCustom4x1() {
        let layout = GridLayout.parse("4x1")
        XCTAssertEqual(layout?.columns, 4)
        XCTAssertEqual(layout?.rows, 1)
    }

    func testParseCustom1x5() {
        let layout = GridLayout.parse("1x5")
        XCTAssertEqual(layout?.columns, 1)
        XCTAssertEqual(layout?.rows, 5)
    }

    // MARK: - parse() 大文字小文字

    func testParseCaseInsensitiveH() {
        XCTAssertNotNil(GridLayout.parse("H"))
        XCTAssertEqual(GridLayout.parse("H")?.columns, 2)
    }

    func testParseCaseInsensitiveV() {
        XCTAssertNotNil(GridLayout.parse("V"))
        XCTAssertEqual(GridLayout.parse("V")?.columns, 1)
    }

    func testParseCaseInsensitiveCustom() {
        let layout = GridLayout.parse("3X2")
        XCTAssertEqual(layout?.columns, 3)
        XCTAssertEqual(layout?.rows, 2)
    }

    // MARK: - parse() 無効入力

    func testParseInvalidZero() {
        XCTAssertNil(GridLayout.parse("0x0"))
    }

    func testParseInvalid9x9() {
        XCTAssertNil(GridLayout.parse("9x9"))
    }

    func testParseInvalid0x1() {
        XCTAssertNil(GridLayout.parse("0x1"))
    }

    func testParseInvalid1x0() {
        XCTAssertNil(GridLayout.parse("1x0"))
    }

    func testParseInvalid10x10() {
        XCTAssertNil(GridLayout.parse("10x10"))
    }

    func testParseInvalidString() {
        XCTAssertNil(GridLayout.parse("invalid"))
    }

    func testParseEmptyString() {
        XCTAssertNil(GridLayout.parse(""))
    }

    func testParseInvalidFormat() {
        XCTAssertNil(GridLayout.parse("2y3"))
    }

    func testParseNegative() {
        XCTAssertNil(GridLayout.parse("-1x2"))
    }

    func testParsePartialX() {
        XCTAssertNil(GridLayout.parse("2x"))
    }

    func testParseJustX() {
        XCTAssertNil(GridLayout.parse("x"))
    }

    func testParseSpaces() {
        XCTAssertNil(GridLayout.parse(" "))
    }

    // MARK: - description

    func testDescription1x1() {
        XCTAssertEqual(GridLayout(columns: 1, rows: 1).description, "分割なし")
    }

    func testDescription2x1() {
        XCTAssertEqual(GridLayout(columns: 2, rows: 1).description, "横2列")
    }

    func testDescription3x1() {
        XCTAssertEqual(GridLayout(columns: 3, rows: 1).description, "横3列")
    }

    func testDescription1x2() {
        XCTAssertEqual(GridLayout(columns: 1, rows: 2).description, "縦2段")
    }

    func testDescription1x3() {
        XCTAssertEqual(GridLayout(columns: 1, rows: 3).description, "縦3段")
    }

    func testDescription2x2() {
        XCTAssertEqual(GridLayout(columns: 2, rows: 2).description, "4分割 (2x2)")
    }

    func testDescription3x3() {
        XCTAssertEqual(GridLayout(columns: 3, rows: 3).description, "9分割 (3x3)")
    }

    func testDescription4x2() {
        XCTAssertEqual(GridLayout(columns: 4, rows: 2).description, "8分割 (4x2)")
    }

    func testDescription2x3() {
        XCTAssertEqual(GridLayout(columns: 2, rows: 3).description, "6分割 (2x3)")
    }

    // MARK: - getAvailableLayouts()

    func testAvailableLayoutsCount() {
        XCTAssertEqual(getAvailableLayouts().count, 7)
    }

    func testAvailableLayoutsShortcuts() {
        let shortcuts = getAvailableLayouts().map { $0.shortcut }
        XCTAssertTrue(shortcuts.contains("h"))
        XCTAssertTrue(shortcuts.contains("v"))
        XCTAssertTrue(shortcuts.contains("4"))
        XCTAssertTrue(shortcuts.contains("6"))
        XCTAssertTrue(shortcuts.contains("8"))
        XCTAssertTrue(shortcuts.contains("9"))
        XCTAssertTrue(shortcuts.contains("CxR"))
    }
}
