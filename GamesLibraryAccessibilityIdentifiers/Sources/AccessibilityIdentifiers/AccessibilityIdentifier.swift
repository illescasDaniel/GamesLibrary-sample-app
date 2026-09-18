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

	/// Shared-process UI test session marker (DEBUG app only).
	public enum UITest {
		public static func ready(sessionGeneration: Int) -> String {
			"uitest-ready-\(sessionGeneration)"
		}
	}
}
