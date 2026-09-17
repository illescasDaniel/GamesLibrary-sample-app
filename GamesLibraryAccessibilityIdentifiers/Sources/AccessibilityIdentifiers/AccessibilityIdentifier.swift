import Foundation

/// Stable accessibility identifier strings shared by the app and UI tests.
public enum AccessibilityIdentifier {
	public enum GamesList {
		public static let screen = "games-list-screen"
		public static let emptyState = "games-list-empty-state"
		public static let loading = "games-list-loading"
		public static let gameRowPrefix = "game-row-"
	}

	public enum GameDetails {
		public static let screen = "game-details-screen"
		public static let loading = "game-details-loading"
		public static let error = "game-details-error"
		public static let description = "game-details-description"
		public static let websiteLink = "game-details-website"
		public static let rating = "game-details-rating"
		public static let year = "game-details-year"
		public static let playtime = "game-details-playtime"
		public static let esrb = "game-details-esrb"
		public static let platforms = "game-details-platforms"
	}

	public static func gameRow(id: Int) -> String {
		"\(GamesList.gameRowPrefix)\(id)"
	}
}

/// Launch-environment keys shared between UI tests and the DEBUG app entry.
public enum UITestEnvironment {
	/// When `"1"`, DEBUG composition root wires an empty `StubGamesRepository`
	/// so the list empty state is reachable without typing into SwiftUI `.searchable`.
	public static let forceEmptyResultsKey = "UITEST_FORCE_EMPTY_RESULTS"

	/// When `"1"`, the stub fails the first details request then succeeds on Retry.
	public static let forceDetailsFailureKey = "UITEST_FORCE_DETAILS_FAILURE"
}
