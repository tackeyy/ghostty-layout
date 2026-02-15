import Foundation

/// Ghosttyの設定ファイルを解析
public struct GhosttyConfigParser {

    /// Ghosttyの設定ファイルパス候補
    public static var configPaths: [URL] {
        let home = FileManager.default.homeDirectoryForCurrentUser
        return [
            home.appendingPathComponent(".config/ghostty/config"),
            home.appendingPathComponent("Library/Application Support/com.mitchellh.ghostty/config")
        ]
    }

    /// Ghosttyの設定を解析してConfigを生成
    public static func parse() -> Config? {
        // 設定ファイルを探す
        guard let configPath = configPaths.first(where: { FileManager.default.fileExists(atPath: $0.path) }) else {
            return nil
        }

        // ファイル検証（symlink + パーミッション）
        let validation = FileHelper.validateFileForReading(configPath)
        if !validation.isValid {
            if let warning = validation.warning {
                print("警告: \(warning)")
            }
            return nil
        }

        guard let content = try? String(contentsOf: configPath, encoding: .utf8) else {
            return nil
        }

        return parseContent(content)
    }

    /// 設定ファイルの内容を解析
    public static func parseContent(_ content: String) -> Config? {
        var keybindings: [String: String] = [:]

        // keybind = ... の行を解析
        let lines = content.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // コメント行をスキップ
            if trimmed.hasPrefix("#") || trimmed.isEmpty {
                continue
            }

            // keybind = key=action 形式を解析
            if trimmed.hasPrefix("keybind") {
                if let binding = parseKeybindLine(trimmed) {
                    keybindings[binding.action] = binding.keys
                }
            }
        }

        // 必要なキーバインドを抽出
        return buildConfig(from: keybindings)
    }

    /// keybind行を解析
    private static func parseKeybindLine(_ line: String) -> (keys: String, action: String)? {
        // "keybind = keys=action" または "keybind=keys=action" 形式
        let parts = line.components(separatedBy: "=")
        guard parts.count >= 3 else { return nil }

        // "keybind" を除いた残りを結合
        let keyActionPart = parts.dropFirst().joined(separator: "=").trimmingCharacters(in: .whitespaces)

        // 最後の "=" で分割（action名に "=" が含まれることはない）
        if let lastEquals = keyActionPart.lastIndex(of: "=") {
            let keys = String(keyActionPart[..<lastEquals]).trimmingCharacters(in: .whitespaces)
            let action = String(keyActionPart[keyActionPart.index(after: lastEquals)...]).trimmingCharacters(in: .whitespaces)
            return (keys, action)
        }

        return nil
    }

    /// キーバインドからConfigを構築
    private static func buildConfig(from keybindings: [String: String]) -> Config? {
        // 必要なアクションが定義されているか確認
        let requiredActions = ["new_split:right", "new_split:down", "goto_split:left", "goto_split:right", "goto_split:up", "goto_split:down"]

        // 少なくとも1つのキーバインドが見つかれば処理を続行
        guard requiredActions.contains(where: { keybindings[$0] != nil }) else {
            return nil
        }

        // プレフィックスを検出（">" が含まれるキーバインドがあればプレフィックス形式）
        var prefix: KeyBinding? = nil
        var hasPrefix = false

        if let sampleKeys = keybindings.values.first(where: { $0.contains(">") }) {
            hasPrefix = true
            if let prefixPart = sampleKeys.components(separatedBy: ">").first {
                prefix = parseKeyBinding(prefixPart.trimmingCharacters(in: .whitespaces))
            }
        }

        // 各アクションのキーバインドを解析
        func getBinding(for action: String, defaultBinding: KeyBinding) -> KeyBinding {
            guard let keys = keybindings[action] else {
                return defaultBinding
            }

            let keyPart: String
            if hasPrefix, let afterPrefix = keys.components(separatedBy: ">").last {
                keyPart = afterPrefix.trimmingCharacters(in: .whitespaces)
            } else {
                keyPart = keys
            }

            return parseKeyBinding(keyPart) ?? defaultBinding
        }

        // equalize_splitsのバインドを取得（Ghostty設定にある場合のみ）
        let equalizeSplitsBinding: KeyBinding?
        if let keys = keybindings["equalize_splits"] {
            let keyPart: String
            if hasPrefix, let afterPrefix = keys.components(separatedBy: ">").last {
                keyPart = afterPrefix.trimmingCharacters(in: .whitespaces)
            } else {
                keyPart = keys
            }
            equalizeSplitsBinding = parseKeyBinding(keyPart)
        } else {
            // Ghostty設定にない場合は nil（デフォルト値は使用しない）
            equalizeSplitsBinding = nil
        }

        return Config(
            prefix: prefix,
            splitRight: getBinding(for: "new_split:right", defaultBinding: Config.defaultConfig.splitRight),
            splitDown: getBinding(for: "new_split:down", defaultBinding: Config.defaultConfig.splitDown),
            gotoLeft: getBinding(for: "goto_split:left", defaultBinding: Config.defaultConfig.gotoLeft),
            gotoRight: getBinding(for: "goto_split:right", defaultBinding: Config.defaultConfig.gotoRight),
            gotoUp: getBinding(for: "goto_split:up", defaultBinding: Config.defaultConfig.gotoUp),
            gotoDown: getBinding(for: "goto_split:down", defaultBinding: Config.defaultConfig.gotoDown),
            equalizeSplits: equalizeSplitsBinding
        )
    }

    /// キーバインド文字列をKeyBindingに変換
    /// 例: "ctrl+t" -> KeyBinding(key: "t", modifiers: ["control"])
    /// 例: "shift+backslash" -> KeyBinding(key: "backslash", modifiers: ["shift"])
    private static func parseKeyBinding(_ str: String) -> KeyBinding? {
        let parts = str.lowercased().components(separatedBy: "+")
        guard !parts.isEmpty else { return nil }

        var modifiers: [String] = []
        var key: String = ""

        for part in parts {
            let trimmed = part.trimmingCharacters(in: .whitespaces)
            switch trimmed {
            case "ctrl", "control":
                modifiers.append("control")
            case "cmd", "super", "command":
                modifiers.append("command")
            case "shift":
                modifiers.append("shift")
            case "alt", "opt", "option":
                modifiers.append("option")
            default:
                key = trimmed
            }
        }

        guard !key.isEmpty else { return nil }
        return KeyBinding(key: key, modifiers: modifiers)
    }
}
