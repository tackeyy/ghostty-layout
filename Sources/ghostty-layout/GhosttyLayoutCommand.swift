import ArgumentParser
import Foundation

@main
struct GhosttyLayoutCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "ghostty-layout",
        abstract: "Ghosttyターミナルの画面分割をコマンドラインから実行",
        version: "0.1.0",
        subcommands: [],
        defaultSubcommand: nil
    )

    @Argument(help: "レイアウト: h(水平2分割), v(垂直2分割), 4(2x2), 6(3x2), 8(4x2)")
    var layout: String?

    @Flag(name: .shortAndLong, help: "利用可能なレイアウト一覧を表示")
    var list: Bool = false

    func run() throws {
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

    private func printLayoutList() {
        print("利用可能なレイアウト:")
        print("  h  - 水平2分割 (左右)")
        print("  v  - 垂直2分割 (上下)")
        print("  4  - 4分割 (2x2)")
        print("  6  - 6分割 (3x2)")
        print("  8  - 8分割 (4x2)")
        print("")
        print("使い方:")
        print("  ghostty-layout <layout>")
        print("  ghostty-layout --list")
    }
}
