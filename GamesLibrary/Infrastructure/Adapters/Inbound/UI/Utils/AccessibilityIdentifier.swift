import Foundation

enum UITestSupport {
	/// Launch environment key: when `"1"`, `StubGamesRepository.forUITests()` returns no games
	/// so the list empty state is reachable without typing into SwiftUI `.searchable`.
	static let forceEmptyResultsEnvironmentKey = "UITEST_FORCE_EMPTY_RESULTS"

	nonisolated static var shouldForceEmptyResults: Bool {
		ProcessInfo.processInfo.environment[forceEmptyResultsEnvironmentKey] == "1"
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
