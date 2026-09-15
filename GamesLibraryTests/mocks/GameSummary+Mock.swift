import GamesLibraryCore

extension GameSummary {
	@MainActor
	static func dummy(id: Int = 1, name: String = "Test Game") -> GameSummary {
		GameSummary(id: GameID(id), name: name, rating: 4.5, released: "2024-01-01")
	}
}

extension GameDetails {
	@MainActor
	static func dummy(id: Int = 1, name: String = "Test Game") -> GameDetails {
		GameDetails(
			summary: GameSummary(id: GameID(id), name: name, rating: 4.5),
			descriptionRaw: "Test description"
		)
	}
}
