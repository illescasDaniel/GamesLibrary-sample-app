import GamesLibraryCore

enum Route: Hashable {
	case gamesList
	case details(GameSummary)
}
