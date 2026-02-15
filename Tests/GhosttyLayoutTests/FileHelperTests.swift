import XCTest
@testable import GhosttyLayoutLib

final class FileHelperTests: XCTestCase {

    var tempDir: URL!

    override func setUp() {
        super.setUp()
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("ghostty-layout-tests-\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDir)
        super.tearDown()
    }

    // MARK: - ヘルパー

    private func createTempFile(name: String = "testfile", content: String = "test", permissions: Int? = nil) -> URL {
        let fileURL = tempDir.appendingPathComponent(name)
        FileManager.default.createFile(atPath: fileURL.path, contents: content.data(using: .utf8))
        if let permissions = permissions {
            try? FileManager.default.setAttributes(
                [.posixPermissions: permissions],
                ofItemAtPath: fileURL.path
            )
        }
        return fileURL
    }

    private func createSymlink(name: String, target: URL) -> URL {
        let symlinkURL = tempDir.appendingPathComponent(name)
        try? FileManager.default.createSymbolicLink(at: symlinkURL, withDestinationURL: target)
        return symlinkURL
    }

    // MARK: - isSymbolicLink

    func testIsSymbolicLinkWithRegularFile() {
        let file = createTempFile()
        XCTAssertFalse(FileHelper.isSymbolicLink(file))
    }

    func testIsSymbolicLinkWithSymlink() {
        let target = createTempFile(name: "target")
        let symlink = createSymlink(name: "link", target: target)
        XCTAssertTrue(FileHelper.isSymbolicLink(symlink))
    }

    func testIsSymbolicLinkWithNonExistentFile() {
        let nonExistent = tempDir.appendingPathComponent("nonexistent")
        XCTAssertFalse(FileHelper.isSymbolicLink(nonExistent))
    }

    // MARK: - hasSecurePermissions

    func testHasSecurePermissionsWithSecureFile() {
        let file = createTempFile(permissions: 0o644)
        XCTAssertTrue(FileHelper.hasSecurePermissions(file))
    }

    func testHasSecurePermissionsWithOwnerOnly() {
        let file = createTempFile(permissions: 0o600)
        XCTAssertTrue(FileHelper.hasSecurePermissions(file))
    }

    func testHasSecurePermissionsWithGroupWritable() {
        let file = createTempFile(permissions: 0o664)
        XCTAssertFalse(FileHelper.hasSecurePermissions(file))
    }

    func testHasSecurePermissionsWithOtherWritable() {
        let file = createTempFile(permissions: 0o646)
        XCTAssertFalse(FileHelper.hasSecurePermissions(file))
    }

    func testHasSecurePermissionsWithWorldWritable() {
        let file = createTempFile(permissions: 0o666)
        XCTAssertFalse(FileHelper.hasSecurePermissions(file))
    }

    func testHasSecurePermissionsWithReadOnly() {
        let file = createTempFile(permissions: 0o444)
        XCTAssertTrue(FileHelper.hasSecurePermissions(file))
    }

    // MARK: - validateFileForReading

    func testValidateRegularSecureFile() {
        let file = createTempFile(permissions: 0o644)
        let result = FileHelper.validateFileForReading(file)
        XCTAssertTrue(result.isValid)
        XCTAssertNil(result.warning)
    }

    func testValidateSymlinkFile() {
        let target = createTempFile(name: "target2")
        let symlink = createSymlink(name: "link2", target: target)
        let result = FileHelper.validateFileForReading(symlink)
        XCTAssertFalse(result.isValid)
        XCTAssertNotNil(result.warning)
    }

    func testValidateInsecurePermissionsStillValid() {
        // パーミッションが安全でなくても isValid は true（警告のみ）
        let file = createTempFile(permissions: 0o666)
        let result = FileHelper.validateFileForReading(file)
        XCTAssertTrue(result.isValid)
    }
}
