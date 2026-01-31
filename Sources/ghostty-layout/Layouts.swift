import Foundation

/// レイアウトの種類
enum Layout: String, CaseIterable {
    case horizontal = "h"
    case vertical = "v"
    case grid4 = "4"
    case grid6 = "6"
    case grid8 = "8"

    var description: String {
        switch self {
        case .horizontal: return "水平2分割"
        case .vertical: return "垂直2分割"
        case .grid4: return "4分割 (2x2)"
        case .grid6: return "6分割 (2x3)"
        case .grid8: return "8分割 (4x2)"
        }
    }

    /// レイアウトを実行
    func execute() {
        switch self {
        case .horizontal:
            executeHorizontal()
        case .vertical:
            executeVertical()
        case .grid4:
            executeGrid4()
        case .grid6:
            executeGrid6()
        case .grid8:
            executeGrid8()
        }
    }

    /// 水平2分割: Cmd+D
    private func executeHorizontal() {
        KeySender.splitHorizontal()
    }

    /// 垂直2分割: Cmd+Shift+D
    private func executeVertical() {
        KeySender.splitVertical()
    }

    /// 4分割 (2x2)
    /// 左を先に分割してから右に戻る（ナビゲーションの確実性のため）
    /// 1. Cmd+D           → [左|右], カーソルは右
    /// 2. Opt+H           → 左に移動（右がまだシンプルなペインのうちに）
    /// 3. Cmd+Shift+D     → 左を下に分割
    /// 4. Opt+L           → 右に移動（右はまだシンプルなペイン）
    /// 5. Cmd+Shift+D     → 右を下に分割
    private func executeGrid4() {
        // [左 | 右] を作成
        KeySender.splitHorizontal()
        KeySender.wait()

        // すぐに左に移動（右を分割する前に）
        KeySender.moveLeft()
        KeySender.wait()

        // 左を上下に分割
        KeySender.splitVertical()
        KeySender.wait()

        // 右に移動（右はまだ分割されていないシンプルなペイン）
        KeySender.moveRight()
        KeySender.wait()

        // 右を上下に分割
        KeySender.splitVertical()
    }

    /// 6分割 (2x3) - 2列 x 3行
    /// 左を先に分割してから右に戻る（ナビゲーションの確実性のため）
    /// 各列は50%幅で均等、各行は50%-25%-25%（バイナリ分割の制約）
    private func executeGrid6() {
        // [左 | 右] を作成
        KeySender.splitHorizontal()
        KeySender.wait()

        // すぐに左に移動（右を分割する前に）
        KeySender.moveLeft()
        KeySender.wait()

        // 左列を3行に分割
        KeySender.splitVertical()
        KeySender.wait()

        KeySender.splitVertical()
        KeySender.wait()

        // 右に移動（右はまだシンプルなペイン）
        KeySender.moveRight()
        KeySender.wait()

        // 右列を3行に分割
        KeySender.splitVertical()
        KeySender.wait()

        KeySender.splitVertical()
    }

    /// 8分割 (4x2) - 4列 x 2行（各列25%幅で均等）
    /// ナビゲーションの確実性のため、シンプルなペインを保ちながら分割
    private func executeGrid8() {
        // Step 1: [50% | 50%], カーソルは右
        KeySender.splitHorizontal()
        KeySender.wait()

        // Step 2: すぐに左に移動（両方がシンプルなペインのうちに）
        KeySender.moveLeft()
        KeySender.wait()

        // Step 3: 左を分割 → [25% | 25% | 50%], カーソルは2番目
        KeySender.splitHorizontal()
        KeySender.wait()

        // Step 4: 右端（50%）に移動（まだシンプルなペイン）
        KeySender.moveRight()
        KeySender.wait()

        // Step 5: 右を分割 → [25% | 25% | 25% | 25%], カーソルは4番目
        KeySender.splitHorizontal()
        KeySender.wait()

        // ここで4つの均等な列が完成
        // 各列を上下に分割（右端から左へ）

        // 4列目（現在位置）を上下分割
        KeySender.splitVertical()
        KeySender.wait()

        // 3列目へ移動して上下分割
        KeySender.moveLeft()
        KeySender.wait()
        KeySender.splitVertical()
        KeySender.wait()

        // 2列目へ移動して上下分割
        KeySender.moveLeft()
        KeySender.wait()
        KeySender.splitVertical()
        KeySender.wait()

        // 1列目へ移動して上下分割
        KeySender.moveLeft()
        KeySender.wait()
        KeySender.splitVertical()
    }
}
