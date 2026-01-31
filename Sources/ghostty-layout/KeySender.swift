import AppKit
import Carbon.HIToolbox

/// キーストローク送信を担当
struct KeySender {

    /// プレフィックス送信後の待機時間（マイクロ秒）
    private static let prefixWaitMicroseconds: UInt32 = 150_000

    /// 現在の設定（起動時にロード）
    static var config: Config = Config.defaultConfig

    /// キーコードのマッピング
    private static let keyCodeMap: [String: UInt16] = [
        "a": 0, "s": 1, "d": 2, "f": 3, "h": 4, "g": 5, "z": 6, "x": 7,
        "c": 8, "v": 9, "b": 11, "q": 12, "w": 13, "e": 14, "r": 15,
        "y": 16, "t": 17, "1": 18, "2": 19, "3": 20, "4": 21, "6": 22,
        "5": 23, "=": 24, "9": 25, "7": 26, "-": 27, "minus": 27,
        "8": 28, "0": 29, "]": 30, "o": 31, "u": 32, "[": 33, "i": 34,
        "p": 35, "return": 36, "enter": 36, "l": 37, "j": 38, "'": 39,
        "k": 40, ";": 41, "\\": 42, "backslash": 42, ",": 43, "/": 44,
        "n": 45, "m": 46, ".": 47, "tab": 48, "space": 49, "`": 50,
        "delete": 51, "backspace": 51, "escape": 53, "esc": 53,
        "left": 123, "right": 124, "down": 125, "up": 126
    ]

    /// 修飾キー
    struct Modifiers: OptionSet {
        let rawValue: CGEventFlags.RawValue

        static let command = Modifiers(rawValue: CGEventFlags.maskCommand.rawValue)
        static let shift = Modifiers(rawValue: CGEventFlags.maskShift.rawValue)
        static let option = Modifiers(rawValue: CGEventFlags.maskAlternate.rawValue)
        static let control = Modifiers(rawValue: CGEventFlags.maskControl.rawValue)

        /// 文字列配列からModifiersを生成
        static func from(_ strings: [String]) -> Modifiers {
            var result: Modifiers = []
            for str in strings {
                switch str.lowercased() {
                case "command", "cmd", "super":
                    result.insert(.command)
                case "shift":
                    result.insert(.shift)
                case "option", "opt", "alt":
                    result.insert(.option)
                case "control", "ctrl":
                    result.insert(.control)
                default:
                    print("警告: 不明な修飾キー '\(str)'")
                }
            }
            return result
        }
    }

    /// キーストロークを送信
    static func send(keyCode: UInt16, modifiers: Modifiers = []) {
        let source = CGEventSource(stateID: .hidSystemState)

        // キーダウン
        if let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true) {
            keyDown.flags = CGEventFlags(rawValue: modifiers.rawValue)
            keyDown.post(tap: .cghidEventTap)
        }

        // キーアップ
        if let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false) {
            keyUp.flags = CGEventFlags(rawValue: modifiers.rawValue)
            keyUp.post(tap: .cghidEventTap)
        }
    }

    /// KeyBindingからキーストロークを送信
    static func send(binding: KeyBinding) {
        guard let keyCode = keyCodeMap[binding.key.lowercased()] else {
            print("警告: 不明なキー '\(binding.key)'")
            return
        }
        let modifiers = Modifiers.from(binding.modifiers)
        send(keyCode: keyCode, modifiers: modifiers)
    }

    /// プレフィックスを送信（設定されている場合）
    private static func sendPrefixIfNeeded() {
        guard let prefix = config.prefix else { return }
        send(binding: prefix)
        usleep(prefixWaitMicroseconds)
    }

    /// 水平分割（右に新しいペイン）
    static func splitHorizontal() {
        sendPrefixIfNeeded()
        send(binding: config.splitRight)
    }

    /// 垂直分割（下に新しいペイン）
    static func splitVertical() {
        sendPrefixIfNeeded()
        send(binding: config.splitDown)
    }

    /// 左のペインに移動
    static func moveLeft() {
        sendPrefixIfNeeded()
        send(binding: config.gotoLeft)
    }

    /// 右のペインに移動
    static func moveRight() {
        sendPrefixIfNeeded()
        send(binding: config.gotoRight)
    }

    /// 下のペインに移動
    static func moveDown() {
        sendPrefixIfNeeded()
        send(binding: config.gotoDown)
    }

    /// 上のペインに移動
    static func moveUp() {
        sendPrefixIfNeeded()
        send(binding: config.gotoUp)
    }

    /// 全ペインを均等化
    static func equalizeSplits() {
        if let binding = config.equalizeSplits {
            // Ghostty設定から読み取ったキーバインドを使用（prefix を送信）
            sendPrefixIfNeeded()
            send(binding: binding)
        } else {
            // デフォルトのキーバインドを使用（prefix なし、Ghosttyのデフォルト）
            let defaultBinding = KeyBinding(key: "=", modifiers: ["command", "control"])
            send(binding: defaultBinding)
        }
    }

    /// 操作間の待機（ミリ秒）
    static func wait(_ milliseconds: UInt32 = 100) {
        // オーバーフロー対策: UInt32.max / 1000 = 4,294,967
        let safeMicroseconds = milliseconds <= 4_294_967 ? milliseconds * 1000 : UInt32.max
        usleep(safeMicroseconds)
    }
}
