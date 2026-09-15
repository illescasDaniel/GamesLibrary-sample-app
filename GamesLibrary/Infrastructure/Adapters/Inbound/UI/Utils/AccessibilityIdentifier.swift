import Foundation

enum UITestSupport {
    static let forceEmptyResultsEnvironmentKey = "UITEST_FORCE_EMPTY_RESULTS"
    static let noResultsSearchQuery = "zzzznonexistentgamequery12345"

    nonisolated static var shouldForceEmptyResults: Bool {
        ProcessInfo.processInfo.environment["UITEST_FORCE_EMPTY_RESULTS"] == "1"
    }
}

enum AccessibilityIdentifier {
    enum GamesList {
        static let screen = "games-list-screen"
        static let emptyState = "games-list-empty-state"
        static let loading = "games-list-loading"
        static let gameRowPrefix = "game-row-"
    }

    enum GameDetails {
        static let screen = "game-details-screen"
    }

    static func gameRow(id: Int) -> String {
        "\(GamesList.gameRowPrefix)\(id)"
    }
}
