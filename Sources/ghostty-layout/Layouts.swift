import Foundation

/// グリッドレイアウト（列×行）
struct GridLayout {
    let columns: Int
    let rows: Int

    /// 文字列からパース（例: "2x3", "3x2"）
    static func parse(_ input: String) -> GridLayout? {
        // グリッド記法: CxR
        let parts = input.lowercased().split(separator: "x")
        if parts.count == 2,
           let cols = Int(parts[0]),
           let rows = Int(parts[1]),
           cols >= 1 && cols <= 8,
           rows >= 1 && rows <= 8 {
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
    var description: String {
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
    func execute() {
        // 1x1 は何もしない
        if columns == 1 && rows == 1 {
            return
        }

        // 縦のみの分割（1列×N行）
        if columns == 1 {
            executeVerticalOnly(rows: rows)
            return
        }

        // 横のみの分割（N列×1行）
        if rows == 1 {
            executeHorizontalOnly(columns: columns)
            return
        }

        // グリッド分割（C列×R行）
        executeGrid(columns: columns, rows: rows)
    }

    /// 縦のみの分割（1列×N行）
    private func executeVerticalOnly(rows: Int) {
        for _ in 1..<rows {
            KeySender.splitVertical()
            KeySender.wait()
        }
    }

    /// 横のみの分割（N列×1行）
    private func executeHorizontalOnly(columns: Int) {
        for _ in 1..<columns {
            KeySender.splitHorizontal()
            KeySender.wait()
        }
    }

    /// グリッド分割（C列×R行）
    /// 均等な列を作るため、左側を先に分割してから右に戻る戦略を使用
    private func executeGrid(columns: Int, rows: Int) {
        // Step 1: 均等な列を作成
        createEqualColumns(count: columns)

        // Step 2: 左端に移動
        moveToLeftmost(columns: columns)

        // Step 3: 各列を行に分割（左から右へ）
        for col in 0..<columns {
            // この列を行に分割
            splitColumnIntoRows(rows: rows)

            // 次の列へ移動（最後の列以外）
            if col < columns - 1 {
                KeySender.moveRight()
                KeySender.wait()
            }
        }
    }

    /// 均等な列を作成
    /// 2のべき乗分割を活用して均等に近い列を作る
    private func createEqualColumns(count: Int) {
        guard count > 1 else { return }

        // 最初の分割
        KeySender.splitHorizontal()
        KeySender.wait()

        if count == 2 {
            return
        }

        // 3列以上: 左に移動してから分割を続ける
        // これにより、シンプルなペインに対してナビゲーションできる
        KeySender.moveLeft()
        KeySender.wait()

        // 残りの列を作成
        // 左側と右側を交互に分割して均等に近づける
        var created = 2
        var onLeft = true

        while created < count {
            KeySender.splitHorizontal()
            KeySender.wait()
            created += 1

            if created < count {
                // 次の分割位置へ移動
                if onLeft {
                    // 右端へ移動
                    for _ in 0..<(created - 1) {
                        KeySender.moveRight()
                        KeySender.wait()
                    }
                    onLeft = false
                } else {
                    // 左端へ移動
                    for _ in 0..<(created - 1) {
                        KeySender.moveLeft()
                        KeySender.wait()
                    }
                    onLeft = true
                }
            }
        }
    }

    /// 左端の列に移動
    private func moveToLeftmost(columns: Int) {
        for _ in 0..<(columns - 1) {
            KeySender.moveLeft()
            KeySender.wait()
        }
    }

    /// 現在の列を行に分割
    private func splitColumnIntoRows(rows: Int) {
        for _ in 1..<rows {
            KeySender.splitVertical()
            KeySender.wait()
        }

        // 分割後、一番上に戻る（次の列の分割のため）
        if rows > 1 {
            for _ in 1..<rows {
                KeySender.moveUp()
                KeySender.wait()
            }
        }
    }
}

/// 利用可能なレイアウトの一覧を取得
func getAvailableLayouts() -> [(shortcut: String, description: String)] {
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
