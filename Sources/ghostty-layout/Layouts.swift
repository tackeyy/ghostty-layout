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
        case .grid6: return "6分割 (3x2)"
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
    /// 1. Cmd+D           → [左|右]
    /// 2. Cmd+Shift+D     → 右を下に分割
    /// 3. Opt+H           → 左に移動
    /// 4. Cmd+Shift+D     → 左を下に分割
    private func executeGrid4() {
        KeySender.splitHorizontal()
        KeySender.wait()

        KeySender.splitVertical()
        KeySender.wait()

        KeySender.moveLeft()
        KeySender.wait()

        KeySender.splitVertical()
    }

    /// 6分割 (3x2)
    /// 1. Cmd+D           → [左|右]
    /// 2. Cmd+D           → [左|中|右]
    /// 3. Cmd+Shift+D     → 右を下に分割
    /// 4. Opt+H           → 中に移動
    /// 5. Cmd+Shift+D     → 中を下に分割
    /// 6. Opt+H           → 左に移動
    /// 7. Cmd+Shift+D     → 左を下に分割
    private func executeGrid6() {
        KeySender.splitHorizontal()
        KeySender.wait()

        KeySender.splitHorizontal()
        KeySender.wait()

        KeySender.splitVertical()
        KeySender.wait()

        KeySender.moveLeft()
        KeySender.wait()

        KeySender.splitVertical()
        KeySender.wait()

        KeySender.moveLeft()
        KeySender.wait()

        KeySender.splitVertical()
    }

    /// 8分割 (4x2)
    /// 1. Cmd+D           → [1|2]
    /// 2. Cmd+D           → [1|2|3]
    /// 3. Cmd+D           → [1|2|3|4]
    /// 4. Cmd+Shift+D     → 4を下に分割
    /// 5-6. 左に移動して下に分割（繰り返し）
    private func executeGrid8() {
        // 4列作成
        KeySender.splitHorizontal()
        KeySender.wait()

        KeySender.splitHorizontal()
        KeySender.wait()

        KeySender.splitHorizontal()
        KeySender.wait()

        // 右端（4列目）を下に分割
        KeySender.splitVertical()
        KeySender.wait()

        // 3列目へ移動して下に分割
        KeySender.moveLeft()
        KeySender.wait()
        KeySender.splitVertical()
        KeySender.wait()

        // 2列目へ移動して下に分割
        KeySender.moveLeft()
        KeySender.wait()
        KeySender.splitVertical()
        KeySender.wait()

        // 1列目へ移動して下に分割
        KeySender.moveLeft()
        KeySender.wait()
        KeySender.splitVertical()
    }
}
