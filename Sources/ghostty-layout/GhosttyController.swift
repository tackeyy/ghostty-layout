import AppKit

/// Ghosttyアプリの制御を担当
struct GhosttyController {

    private static let bundleIdentifier = "com.mitchellh.ghostty"

    /// Ghosttyをアクティブにする
    @discardableResult
    static func activate() -> Bool {
        guard let app = NSRunningApplication.runningApplications(
            withBundleIdentifier: bundleIdentifier
        ).first else {
            return false
        }

        return app.activate(options: [.activateIgnoringOtherApps])
    }

    /// Ghosttyが起動しているか確認
    static func isRunning() -> Bool {
        return !NSRunningApplication.runningApplications(
            withBundleIdentifier: bundleIdentifier
        ).isEmpty
    }

    /// Ghosttyを起動
    static func launch() {
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) {
            NSWorkspace.shared.openApplication(at: url, configuration: .init())
        }
    }

    /// Accessibility権限があるか確認
    static func checkAccessibility() -> Bool {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        return AXIsProcessTrustedWithOptions(options)
    }
}
