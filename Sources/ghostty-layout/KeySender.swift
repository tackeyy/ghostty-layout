import AppKit
import Carbon.HIToolbox

/// キーストローク送信を担当
struct KeySender {

    /// キーコードの定義
    enum KeyCode: UInt16 {
        case d = 2
        case h = 4
        case l = 37
        case j = 38
        case k = 40
    }

    /// 修飾キー
    struct Modifiers: OptionSet {
        let rawValue: CGEventFlags.RawValue

        static let command = Modifiers(rawValue: CGEventFlags.maskCommand.rawValue)
        static let shift = Modifiers(rawValue: CGEventFlags.maskShift.rawValue)
        static let option = Modifiers(rawValue: CGEventFlags.maskAlternate.rawValue)
        static let control = Modifiers(rawValue: CGEventFlags.maskControl.rawValue)
    }

    /// キーストロークを送信
    static func send(keyCode: KeyCode, modifiers: Modifiers = []) {
        let source = CGEventSource(stateID: .hidSystemState)

        // キーダウン
        if let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode.rawValue, keyDown: true) {
            keyDown.flags = CGEventFlags(rawValue: modifiers.rawValue)
            keyDown.post(tap: .cghidEventTap)
        }

        // キーアップ
        if let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCode.rawValue, keyDown: false) {
            keyUp.flags = CGEventFlags(rawValue: modifiers.rawValue)
            keyUp.post(tap: .cghidEventTap)
        }
    }

    /// Cmd+D: 水平分割（右に新しいペイン）
    static func splitHorizontal() {
        send(keyCode: .d, modifiers: .command)
    }

    /// Cmd+Shift+D: 垂直分割（下に新しいペイン）
    static func splitVertical() {
        send(keyCode: .d, modifiers: [.command, .shift])
    }

    /// Opt+H: 左のペインに移動
    static func moveLeft() {
        send(keyCode: .h, modifiers: .option)
    }

    /// Opt+L: 右のペインに移動
    static func moveRight() {
        send(keyCode: .l, modifiers: .option)
    }

    /// Opt+J: 下のペインに移動
    static func moveDown() {
        send(keyCode: .j, modifiers: .option)
    }

    /// Opt+K: 上のペインに移動
    static func moveUp() {
        send(keyCode: .k, modifiers: .option)
    }

    /// 操作間の待機（ミリ秒）
    static func wait(_ milliseconds: UInt32 = 80) {
        usleep(milliseconds * 1000)
    }
}
