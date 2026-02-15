import Foundation

/// グリッドレイアウト（列×行）
public struct GridLayout {
    public let columns: Int
    public let rows: Int

    /// グリッドサイズの最小値
    private static let minGridSize = 1
    /// グリッドサイズの最大値（パフォーマンスとユーザビリティのため）
    private static let maxGridSize = 8

    public init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
    }

    /// 文字列からパース（例: "2x3", "3x2"）
    public static func parse(_ input: String) -> GridLayout? {
        // グリッド記法: CxR
        let parts = input.lowercased().split(separator: "x")
        if parts.count == 2,
           let cols = Int(parts[0]),
           let rows = Int(parts[1]),
           cols >= minGridSize && cols <= maxGridSize,
           rows >= minGridSize && rows <= maxGridSize {
            return GridLayout(columns: cols, rows: rows)
        }

        // エイリアス
        switch input.lowercased() {
        case "h":
            return GridLayout(columns: 2, rows: 1)
        case "v":
            return GridLayout(columns: 1, rows: 2)
        case "4":
            return GridLayout(columns: 2, rows: 2)
        case "6":
            return GridLayout(columns: 2, rows: 3)
        case "8":
            return GridLayout(columns: 4, rows: 2)
        case "9":
            return GridLayout(columns: 3, rows: 3)
        default:
            return nil
        }
    }

    /// 説明文字列
    public var description: String {
        let total = columns * rows
        if columns == 1 && rows == 1 {
            return "分割なし"
        } else if columns == 1 {
            return "縦\(rows)段"
        } else if rows == 1 {
            return "横\(columns)列"
        } else {
            return "\(total)分割 (\(columns)x\(rows))"
        }
    }

    /// レイアウトを実行
    public func execute(keySender: KeySending = KeySenderAdapter()) {
        // 1x1 は何もしない
        if columns == 1 && rows == 1 {
            return
        }

        // 縦のみの分割（1列×N行）
        if columns == 1 {
            executeVerticalOnly(rows: rows, keySender: keySender)
            return
        }

        // 横のみの分割（N列×1行）
        if rows == 1 {
            executeHorizontalOnly(columns: columns, keySender: keySender)
            return
        }

        // グリッド分割（C列×R行）
        executeGrid(columns: columns, rows: rows, keySender: keySender)
    }

    /// 縦のみの分割（1列×N行）
    private func executeVerticalOnly(rows: Int, keySender: KeySending) {
        for _ in 1..<rows {
            keySender.splitVertical()
            keySender.wait(100)
        }
        keySender.equalizeSplits()
    }

    /// 横のみの分割（N列×1行）
    private func executeHorizontalOnly(columns: Int, keySender: KeySending) {
        for _ in 1..<columns {
            keySender.splitHorizontal()
            keySender.wait(100)
        }
        keySender.equalizeSplits()
    }

    /// グリッド分割（C列×R行）
    /// 均等な列を作るため、左側を先に分割してから右に戻る戦略を使用
    private func executeGrid(columns: Int, rows: Int, keySender: KeySending) {
        // Step 1: 均等な列を作成
        createEqualColumns(count: columns, keySender: keySender)

        // Step 2: 左端に移動
        moveToLeftmost(columns: columns, keySender: keySender)

        // Step 3: 各列を行に分割（左から右へ）
        for col in 0..<columns {
            // この列を行に分割
            splitColumnIntoRows(rows: rows, keySender: keySender)

            // 次の列へ移動（最後の列以外）
            if col < columns - 1 {
                keySender.moveRight()
                keySender.wait(100)
            }
        }

        // Step 4: 全ペインを均等化
        keySender.equalizeSplits()
    }

    /// 均等な列を作成
    /// シンプルなペインに対してのみナビゲーションを行い、確実性を高める
    private func createEqualColumns(count: Int, keySender: KeySending) {
        guard count > 1 else { return }

        // 2列: 単純に分割
        // [50% | 50%]
        keySender.splitHorizontal()
        keySender.wait(100)

        if count == 2 {
            return
        }

        // 3列以上: 左に移動してから左側を分割
        // これにより右側がシンプルなペインのままになる
        keySender.moveLeft()
        keySender.wait(150)  // 長めに待機

        // 3列目: 左を分割 → [25% | 25% | 50%]
        keySender.splitHorizontal()
        keySender.wait(100)

        if count == 3 {
            return
        }

        // 4列: 右端（50%）を分割 → [25% | 25% | 25% | 25%]
        // 右端に移動（2回）
        keySender.moveRight()
        keySender.wait(150)
        keySender.moveRight()
        keySender.wait(150)

        keySender.splitHorizontal()
        keySender.wait(100)

        if count == 4 {
            return
        }

        // 5列以上: 順次右端を分割していく
        for _ in 5...count {
            keySender.splitHorizontal()
            keySender.wait(100)
        }
    }

    /// 左端の列に移動
    private func moveToLeftmost(columns: Int, keySender: KeySending) {
        for _ in 0..<(columns - 1) {
            keySender.moveLeft()
            keySender.wait(100)
        }
    }

    /// 現在の列を行に分割
    private func splitColumnIntoRows(rows: Int, keySender: KeySending) {
        for _ in 1..<rows {
            keySender.splitVertical()
            keySender.wait(100)
        }

        // 分割後、一番上に戻る（次の列の分割のため）
        if rows > 1 {
            for _ in 1..<rows {
                keySender.moveUp()
                keySender.wait(100)
            }
        }
    }
}

/// 利用可能なレイアウトの一覧を取得
public func getAvailableLayouts() -> [(shortcut: String, description: String)] {
    return [
        ("h", "横2列 (2x1)"),
        ("v", "縦2段 (1x2)"),
        ("4", "4分割 (2x2)"),
        ("6", "6分割 (2x3)"),
        ("8", "8分割 (4x2)"),
        ("9", "9分割 (3x3)"),
        ("CxR", "任意のグリッド（例: 3x2, 2x4）"),
    ]
}
