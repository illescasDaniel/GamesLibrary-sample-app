import Testing
import Foundation

@Suite
struct CoreImportGuardTests {

    @Test
    func coreSourcesMustNotImportUIFrameworks() throws {
        let coreSourcesURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Sources/GamesLibraryCore")

        let forbiddenImports = ["import SwiftUI", "import UIKit", "import SwiftData"]
        var violations: [String] = []

        let enumerator = FileManager.default.enumerator(
            at: coreSourcesURL,
            includingPropertiesForKeys: nil
        )
        while let fileURL = enumerator?.nextObject() as? URL {
            guard fileURL.pathExtension == "swift" else { continue }
            let contents = try String(contentsOf: fileURL, encoding: .utf8)
            for forbidden in forbiddenImports {
                if contents.contains(forbidden) {
                    violations.append("\(fileURL.lastPathComponent): \(forbidden)")
                }
            }
        }

        #expect(violations.isEmpty, "Forbidden imports found: \(violations.joined(separator: ", "))")
    }
}
