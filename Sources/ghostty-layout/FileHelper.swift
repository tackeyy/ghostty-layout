import Foundation

/// ファイル操作のヘルパー
enum FileHelper {
    /// ファイルがシンボリックリンクかどうかをチェック
    /// - Returns: symlink の場合は true、それ以外は false
    static func isSymbolicLink(_ url: URL) -> Bool {
        do {
            let resourceValues = try url.resourceValues(forKeys: [.isSymbolicLinkKey])
            return resourceValues.isSymbolicLink == true
        } catch {
            return false
        }
    }

    /// ファイルのパーミッションが安全かどうかをチェック（所有者のみ読み書き可能）
    static func hasSecurePermissions(_ url: URL) -> Bool {
        let fileManager = FileManager.default
        guard let attributes = try? fileManager.attributesOfItem(atPath: url.path),
              let permissions = attributes[.posixPermissions] as? Int else {
            return true  // 属性取得失敗時はスキップ
        }
        // グループ・その他に書き込み権限がないことを確認 (0o022)
        return (permissions & 0o022) == 0
    }

    /// ファイルを安全に読み込む（symlink チェック + パーミッションチェック）
    /// - Returns: ファイルが安全でない場合は nil と警告メッセージ
    static func validateFileForReading(_ url: URL) -> (isValid: Bool, warning: String?) {
        // symlink チェック
        if isSymbolicLink(url) {
            return (false, "設定ファイルがシンボリックリンクのためスキップしました: \(url.path)")
        }

        // パーミッションチェック（警告のみ、読み込みは続行）
        if !hasSecurePermissions(url) {
            print("警告: 設定ファイルのパーミッションが安全ではありません（グループ/その他に書き込み権限があります）: \(url.path)")
        }

        return (true, nil)
    }
}
