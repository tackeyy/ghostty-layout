import ArgumentParser
import Foundation

@main
struct GhosttyLayoutCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "ghostty-layout",
        abstract: "Ghosttyターミナルの画面分割をコマンドラインから実行",
        version: "0.2.0",
        subcommands: [],
        defaultSubcommand: nil
    )

    @Argument(help: "レイアウト: h(水平2分割), v(垂直2分割), 4(2x2), 6(2x3), 8(4x2)")
    var layout: String?

    @Flag(name: .shortAndLong, help: "利用可能なレイアウト一覧を表示")
    var list: Bool = false

    @Flag(name: .long, help: "設定ファイルを再生成（Ghosttyの設定から読み込み）")
    var initConfig: Bool = false

    @Flag(name: .long, help: "現在の設定を表示")
    var showConfig: Bool = false

    func run() throws {
        // 設定ファイルの再生成
        if initConfig {
            try regenerateConfig()
            return
        }

        // 設定を表示
        if showConfig {
            showCurrentConfig()
            return
        }

        // リスト表示
        if list {
            printLayoutList()
            return
        }

        // レイアウト引数がない場合
        guard let layoutArg = layout else {
            print("エラー: レイアウトを指定してください")
            print("")
            printLayoutList()
            throw ExitCode.failure
        }

        // レイアウトのパース
        guard let selectedLayout = Layout(rawValue: layoutArg) else {
            print("エラー: 不明なレイアウト '\(layoutArg)'")
            print("")
            printLayoutList()
            throw ExitCode.failure
        }

        // 設定を読み込み（初回は自動生成）
        KeySender.config = Config.loadOrCreate()

        // Accessibility権限チェック
        guard GhosttyController.checkAccessibility() else {
            print("エラー: Accessibility権限が必要です")
            print("システム設定 > プライバシーとセキュリティ > アクセシビリティ で許可してください")
            throw ExitCode.failure
        }

        // Ghosttyが起動しているか確認
        guard GhosttyController.isRunning() else {
            print("エラー: Ghosttyが起動していません")
            print("Ghosttyを起動してから再実行してください")
            throw ExitCode.failure
        }

        // Ghosttyをアクティブにする
        guard GhosttyController.activate() else {
            print("エラー: Ghosttyをアクティブにできませんでした")
            throw ExitCode.failure
        }

        // アクティブ化を待つ
        usleep(100_000) // 100ms

        // レイアウト実行
        selectedLayout.execute()

        print("✓ \(selectedLayout.description)を適用しました")
    }

    /// 設定ファイルを再生成
    private func regenerateConfig() throws {
        // 既存の設定を削除
        let configPath = Config.configPath
        if FileManager.default.fileExists(atPath: configPath.path) {
            try FileManager.default.removeItem(at: configPath)
            print("既存の設定ファイルを削除しました")
        }

        // 新規生成
        let config = Config.loadOrCreate()
        print("")
        printConfigSummary(config)
    }

    /// 現在の設定を表示
    private func showCurrentConfig() {
        let config = Config.loadOrCreate()
        print("設定ファイル: \(Config.configPath.path)")
        print("")
        printConfigSummary(config)
    }

    /// 設定のサマリを表示
    private func printConfigSummary(_ config: Config) {
        print("現在のキーバインド:")
        if let prefix = config.prefix {
            print("  プレフィックス: \(formatBinding(prefix))")
        }
        print("  水平分割 (右): \(formatBindingWithPrefix(config.splitRight, prefix: config.prefix))")
        print("  垂直分割 (下): \(formatBindingWithPrefix(config.splitDown, prefix: config.prefix))")
        print("  左に移動:      \(formatBindingWithPrefix(config.gotoLeft, prefix: config.prefix))")
        print("  右に移動:      \(formatBindingWithPrefix(config.gotoRight, prefix: config.prefix))")
        print("  上に移動:      \(formatBindingWithPrefix(config.gotoUp, prefix: config.prefix))")
        print("  下に移動:      \(formatBindingWithPrefix(config.gotoDown, prefix: config.prefix))")
    }

    /// キーバインドを文字列にフォーマット
    private func formatBinding(_ binding: KeyBinding) -> String {
        if binding.modifiers.isEmpty {
            return binding.key
        }
        return binding.modifiers.joined(separator: "+") + "+" + binding.key
    }

    /// プレフィックス付きでキーバインドをフォーマット
    private func formatBindingWithPrefix(_ binding: KeyBinding, prefix: KeyBinding?) -> String {
        let keyPart = formatBinding(binding)
        if let prefix = prefix {
            return "\(formatBinding(prefix)) > \(keyPart)"
        }
        return keyPart
    }

    private func printLayoutList() {
        print("利用可能なレイアウト:")
        print("  h  - 水平2分割 (左右)")
        print("  v  - 垂直2分割 (上下)")
        print("  4  - 4分割 (2x2)")
        print("  6  - 6分割 (2x3)")
        print("  8  - 8分割 (4x2)")
        print("")
        print("使い方:")
        print("  ghostty-layout <layout>")
        print("  ghostty-layout --list")
        print("  ghostty-layout --show-config")
        print("  ghostty-layout --init-config")
    }
}
