import Foundation

/// キーバインド設定
public struct KeyBinding: Codable {
    public let key: String
    public let modifiers: [String]

    public init(key: String, modifiers: [String] = []) {
        self.key = key
        self.modifiers = modifiers
    }
}

/// ghostty-layout の設定
public struct Config: Codable {
    public var prefix: KeyBinding?
    public var splitRight: KeyBinding
    public var splitDown: KeyBinding
    public var gotoLeft: KeyBinding
    public var gotoRight: KeyBinding
    public var gotoUp: KeyBinding
    public var gotoDown: KeyBinding
    public var equalizeSplits: KeyBinding?

    public init(prefix: KeyBinding? = nil, splitRight: KeyBinding, splitDown: KeyBinding, gotoLeft: KeyBinding, gotoRight: KeyBinding, gotoUp: KeyBinding, gotoDown: KeyBinding, equalizeSplits: KeyBinding? = nil) {
        self.prefix = prefix
        self.splitRight = splitRight
        self.splitDown = splitDown
        self.gotoLeft = gotoLeft
        self.gotoRight = gotoRight
        self.gotoUp = gotoUp
        self.gotoDown = gotoDown
        self.equalizeSplits = equalizeSplits
    }

    /// デフォルト設定（Ghosttyのデフォルトキーバインド）
    public static let defaultConfig = Config(
        prefix: nil,
        splitRight: KeyBinding(key: "d", modifiers: ["command"]),
        splitDown: KeyBinding(key: "d", modifiers: ["command", "shift"]),
        gotoLeft: KeyBinding(key: "left", modifiers: ["command", "control"]),
        gotoRight: KeyBinding(key: "right", modifiers: ["command", "control"]),
        gotoUp: KeyBinding(key: "up", modifiers: ["command", "control"]),
        gotoDown: KeyBinding(key: "down", modifiers: ["command", "control"]),
        equalizeSplits: KeyBinding(key: "=", modifiers: ["command", "control"])
    )

    /// 設定ファイルのパス
    public static var configPath: URL {
        let configDir = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".config")
            .appendingPathComponent("ghostty-layout")
        return configDir.appendingPathComponent("config.json")
    }

    /// 設定ディレクトリを作成
    public static func ensureConfigDirectory() throws {
        let configDir = configPath.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: configDir, withIntermediateDirectories: true)
    }

    /// 設定を読み込む
    public static func load() -> Config? {
        guard FileManager.default.fileExists(atPath: configPath.path) else {
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

        do {
            let data = try Data(contentsOf: configPath)
            let decoder = JSONDecoder()
            return try decoder.decode(Config.self, from: data)
        } catch {
            print("警告: 設定ファイルの読み込みに失敗しました: \(error.localizedDescription)")
            return nil
        }
    }

    /// 設定を保存
    public func save() throws {
        try Config.ensureConfigDirectory()

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(self)
        try data.write(to: Config.configPath)
    }

    /// 設定をロードまたは生成
    public static func loadOrCreate() -> Config {
        // 既存の設定があれば読み込む
        if let existing = load() {
            return existing
        }

        // Ghosttyの設定を解析して新規作成
        let ghosttyConfig = GhosttyConfigParser.parse()
        let config = ghosttyConfig ?? defaultConfig

        // 設定を保存
        do {
            try config.save()
            if ghosttyConfig != nil {
                print("Ghosttyの設定から設定ファイルを生成しました: \(configPath.path)")
            } else {
                print("デフォルト設定ファイルを生成しました: \(configPath.path)")
            }
        } catch {
            print("警告: 設定ファイルの保存に失敗しました: \(error.localizedDescription)")
        }

        return config
    }
}
