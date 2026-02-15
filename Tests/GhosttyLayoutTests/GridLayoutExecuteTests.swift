import XCTest
@testable import GhosttyLayoutLib

/// テスト用のKeySenderモック
final class MockKeySender: KeySending {
    var actions: [String] = []

    func splitHorizontal() { actions.append("splitH") }
    func splitVertical() { actions.append("splitV") }
    func moveLeft() { actions.append("moveL") }
    func moveRight() { actions.append("moveR") }
    func moveUp() { actions.append("moveU") }
    func moveDown() { actions.append("moveD") }
    func equalizeSplits() { actions.append("equalize") }
    func wait(_ milliseconds: UInt32) { actions.append("wait(\(milliseconds))") }
}

final class GridLayoutExecuteTests: XCTestCase {

    var mock: MockKeySender!

    override func setUp() {
        super.setUp()
        mock = MockKeySender()
    }

    // MARK: - 1x1 (何もしない)

    func testExecute1x1DoesNothing() {
        GridLayout(columns: 1, rows: 1).execute(keySender: mock)
        XCTAssertTrue(mock.actions.isEmpty)
    }

    // MARK: - 垂直のみ (1xN)

    func testExecute1x2VerticalOnly() {
        GridLayout(columns: 1, rows: 2).execute(keySender: mock)
        XCTAssertEqual(mock.actions.filter { $0 == "splitV" }.count, 1)
        XCTAssertEqual(mock.actions.last, "equalize")
    }

    func testExecute1x3VerticalOnly() {
        GridLayout(columns: 1, rows: 3).execute(keySender: mock)
        XCTAssertEqual(mock.actions.filter { $0 == "splitV" }.count, 2)
        XCTAssertEqual(mock.actions.last, "equalize")
    }

    func testExecute1x4VerticalOnly() {
        GridLayout(columns: 1, rows: 4).execute(keySender: mock)
        XCTAssertEqual(mock.actions.filter { $0 == "splitV" }.count, 3)
        XCTAssertEqual(mock.actions.last, "equalize")
    }

    // MARK: - 水平のみ (Nx1)

    func testExecute2x1HorizontalOnly() {
        GridLayout(columns: 2, rows: 1).execute(keySender: mock)
        XCTAssertEqual(mock.actions.filter { $0 == "splitH" }.count, 1)
        XCTAssertEqual(mock.actions.last, "equalize")
    }

    func testExecute3x1HorizontalOnly() {
        GridLayout(columns: 3, rows: 1).execute(keySender: mock)
        XCTAssertEqual(mock.actions.filter { $0 == "splitH" }.count, 2)
        XCTAssertEqual(mock.actions.last, "equalize")
    }

    func testExecute4x1HorizontalOnly() {
        GridLayout(columns: 4, rows: 1).execute(keySender: mock)
        XCTAssertEqual(mock.actions.filter { $0 == "splitH" }.count, 3)
        XCTAssertEqual(mock.actions.last, "equalize")
    }

    // MARK: - グリッド (CxR)

    func testExecute2x2Grid() {
        GridLayout(columns: 2, rows: 2).execute(keySender: mock)
        let splitHCount = mock.actions.filter { $0 == "splitH" }.count
        let splitVCount = mock.actions.filter { $0 == "splitV" }.count
        let equalizeCount = mock.actions.filter { $0 == "equalize" }.count

        XCTAssertEqual(splitHCount, 1, "2列なのでsplitH 1回")
        XCTAssertEqual(splitVCount, 2, "2列x(2-1)行 = splitV 2回")
        XCTAssertEqual(equalizeCount, 1, "equalize 1回")
    }

    func testExecute3x3Grid() {
        GridLayout(columns: 3, rows: 3).execute(keySender: mock)
        let splitHCount = mock.actions.filter { $0 == "splitH" }.count
        let splitVCount = mock.actions.filter { $0 == "splitV" }.count

        XCTAssertEqual(splitHCount, 2, "3列なのでsplitH 2回")
        XCTAssertEqual(splitVCount, 6, "3列 x 2行分割 = splitV 6回")
    }

    func testExecute4x2Grid() {
        GridLayout(columns: 4, rows: 2).execute(keySender: mock)
        let splitHCount = mock.actions.filter { $0 == "splitH" }.count
        let splitVCount = mock.actions.filter { $0 == "splitV" }.count

        XCTAssertEqual(splitHCount, 3, "4列なのでsplitH 3回")
        XCTAssertEqual(splitVCount, 4, "4列 x 1行分割 = splitV 4回")
    }

    func testExecute2x3Grid() {
        GridLayout(columns: 2, rows: 3).execute(keySender: mock)
        let splitVCount = mock.actions.filter { $0 == "splitV" }.count
        XCTAssertEqual(splitVCount, 4, "2列 x 2行分割 = splitV 4回")
    }

    // MARK: - createEqualColumns の検証

    func testExecute2ColumnsCreation() {
        GridLayout(columns: 2, rows: 2).execute(keySender: mock)
        XCTAssertEqual(mock.actions.first, "splitH")
    }

    func testExecute3ColumnsCreation() {
        // rows > 1 でグリッドパスを通す（createEqualColumnsが呼ばれる）
        GridLayout(columns: 3, rows: 2).execute(keySender: mock)
        XCTAssertEqual(mock.actions.filter { $0 == "splitH" }.count, 2)
        XCTAssertTrue(mock.actions.contains("moveL"))
    }

    func testExecute4ColumnsCreation() {
        // rows > 1 でグリッドパスを通す（createEqualColumnsが呼ばれる）
        GridLayout(columns: 4, rows: 2).execute(keySender: mock)
        XCTAssertEqual(mock.actions.filter { $0 == "splitH" }.count, 3)
        XCTAssertTrue(mock.actions.contains("moveL"))
        XCTAssertTrue(mock.actions.contains("moveR"))
    }

    func testExecute5ColumnsCreation() {
        // rows > 1 でグリッドパスを通す（createEqualColumnsが呼ばれる）
        GridLayout(columns: 5, rows: 2).execute(keySender: mock)
        XCTAssertEqual(mock.actions.filter { $0 == "splitH" }.count, 4)
    }

    // MARK: - moveToLeftmost の検証

    func testExecuteGridMovesToLeftmost() {
        GridLayout(columns: 3, rows: 2).execute(keySender: mock)
        let moveLCount = mock.actions.filter { $0 == "moveL" }.count
        // createEqualColumnsの1回 + moveToLeftmostの2回 = 3回
        XCTAssertEqual(moveLCount, 3, "createEqualColumnsで1回 + moveToLeftmostで2回 = moveL 3回")
    }

    // MARK: - splitColumnIntoRows の検証

    func testExecuteGridSplitsColumnsIntoRows() {
        GridLayout(columns: 2, rows: 3).execute(keySender: mock)
        let moveUpCount = mock.actions.filter { $0 == "moveU" }.count
        // 2列 x (3-1)回 = moveUp 4回
        XCTAssertEqual(moveUpCount, 4, "各列の分割後にtopに戻るためmoveUp")
    }

    // MARK: - equalize が最後に呼ばれる

    func testExecuteEndsWithEqualize() {
        GridLayout(columns: 2, rows: 2).execute(keySender: mock)
        XCTAssertEqual(mock.actions.last, "equalize")
    }

    func testExecuteVerticalEndsWithEqualize() {
        GridLayout(columns: 1, rows: 3).execute(keySender: mock)
        XCTAssertEqual(mock.actions.last, "equalize")
    }

    func testExecuteHorizontalEndsWithEqualize() {
        GridLayout(columns: 3, rows: 1).execute(keySender: mock)
        XCTAssertEqual(mock.actions.last, "equalize")
    }

    // MARK: - wait のタイミング

    func testExecuteWaitAfterSplit() {
        GridLayout(columns: 1, rows: 2).execute(keySender: mock)
        if let splitIndex = mock.actions.firstIndex(of: "splitV") {
            XCTAssertTrue(splitIndex + 1 < mock.actions.count)
            XCTAssertTrue(mock.actions[splitIndex + 1].hasPrefix("wait"))
        } else {
            XCTFail("splitV が見つからない")
        }
    }

    func testExecuteWait150ForNavigation() {
        // rows > 1 でグリッドパスを通す（createEqualColumnsのmoveLeft後にwait(150)）
        GridLayout(columns: 3, rows: 2).execute(keySender: mock)
        XCTAssertTrue(mock.actions.contains("wait(150)"), "createEqualColumnsのmoveLeft後のwaitは150ms")
    }

    // MARK: - アクションシーケンスの完全検証

    func testExecute1x2ExactSequence() {
        GridLayout(columns: 1, rows: 2).execute(keySender: mock)
        XCTAssertEqual(mock.actions, ["splitV", "wait(100)", "equalize"])
    }

    func testExecute2x1ExactSequence() {
        GridLayout(columns: 2, rows: 1).execute(keySender: mock)
        XCTAssertEqual(mock.actions, ["splitH", "wait(100)", "equalize"])
    }

    func testExecute3x1ExactSequence() {
        // 3x1 は executeHorizontalOnly パス（createEqualColumnsは通らない）
        GridLayout(columns: 3, rows: 1).execute(keySender: mock)
        let expected = [
            "splitH", "wait(100)",
            "splitH", "wait(100)",
            "equalize"
        ]
        XCTAssertEqual(mock.actions, expected)
    }

    func testExecute1x3ExactSequence() {
        GridLayout(columns: 1, rows: 3).execute(keySender: mock)
        let expected = [
            "splitV", "wait(100)",
            "splitV", "wait(100)",
            "equalize"
        ]
        XCTAssertEqual(mock.actions, expected)
    }
}
